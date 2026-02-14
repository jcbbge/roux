#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# roux verify — Skill Ecosystem Consistency Checker
# ═══════════════════════════════════════════════════════════════
#
# A read-only checker for your personal agentic skill ecosystem.
# Validates symlinks, config files, hooks, and manifest consistency
# across Claude Code, OpenCode, and the source of truth.
#
# NEVER modifies any file. Read-only.
#
# Exit codes:
#   0 = all checks pass (may have info notes)
#   1 = warnings only (non-critical inconsistencies)
#   2 = failures detected (broken symlinks, missing skills, etc.)
#   3 = checker error (couldn't read directory, etc.)
#
# Dependencies: bash, readlink (all macOS defaults)
#               jq (optional, for manifest parsing)
#
# Usage: ~/.roux/verify.sh
# ═══════════════════════════════════════════════════════════════

set -uo pipefail

# ── Hardcoded Paths (personal tool) ──────────────────────────

SOURCE_DIR="$HOME/Documents/metaprompts/_skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
OPENCODE_SKILLS="$HOME/.config/opencode/skills"
CLAUDE_CONFIG="$HOME/.claude/CLAUDE.md"
OPENCODE_CONFIG="$HOME/.config/opencode/AGENTS.md"
CLAUDE_HOOKS="$HOME/.claude/hooks"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
MANIFEST="$HOME/.roux/manifest.json"

# ── Counters ─────────────────────────────────────────────────

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# ── Output Helpers ───────────────────────────────────────────

_pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "  ✅ $*"; }
_warn() { WARN_COUNT=$((WARN_COUNT + 1)); echo "  ⚠️  $*"; }
_fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "  ❌ $*"; }
_info() { echo "  ℹ️  $*"; }

# ── Utility: check if value is in a space-separated list ─────
# Usage: in_list "value" "item1 item2 item3"
in_list() {
  local needle="$1"
  local haystack="$2"
  local item
  for item in $haystack; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

# ── Header ───────────────────────────────────────────────────

echo ""
echo "╭─────────────────────────────────╮"
echo "│       roux verify               │"
echo "│       $(date +%Y-%m-%d)                │"
echo "╰─────────────────────────────────╯"
echo ""

# ══════════════════════════════════════════════════════════════
# PHASE 1: Source Directory
# ══════════════════════════════════════════════════════════════

echo "Source: $SOURCE_DIR"

if [ ! -d "$SOURCE_DIR" ]; then
  _fail "Source directory does not exist!"
  echo ""
  echo "Cannot continue without source directory."
  exit 3
fi

# Collect active skills as a space-separated string (bash 3.2 compatible)
SOURCE_SKILL_LIST=""
SOURCE_MISSING_SKILLMD=""
SKILL_COUNT=0

for dir in "$SOURCE_DIR"/*/; do
  [ ! -d "$dir" ] && continue
  name=$(basename "$dir")
  [ "$name" = "_deprecated" ] && continue
  [ "$name" = ".git" ] && continue
  if [ -f "$dir/SKILL.md" ]; then
    SOURCE_SKILL_LIST="$SOURCE_SKILL_LIST $name"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  else
    SOURCE_MISSING_SKILLMD="$SOURCE_MISSING_SKILLMD $name"
  fi
done

# Trim leading space
SOURCE_SKILL_LIST="${SOURCE_SKILL_LIST# }"
SOURCE_MISSING_SKILLMD="${SOURCE_MISSING_SKILLMD# }"

if [ -n "$SOURCE_MISSING_SKILLMD" ]; then
  missing_md_count=0
  for _ in $SOURCE_MISSING_SKILLMD; do missing_md_count=$((missing_md_count + 1)); done
  _warn "$SKILL_COUNT active skills found, $missing_md_count missing SKILL.md"
  for s in $SOURCE_MISSING_SKILLMD; do
    echo "       missing SKILL.md: $s"
  done
else
  _pass "$SKILL_COUNT active skills found"
fi
echo ""

# ══════════════════════════════════════════════════════════════
# HELPER: Check a tool's skills directory
# ══════════════════════════════════════════════════════════════
# Args: $1 = label, $2 = skills_dir path
# Uses: SOURCE_SKILL_LIST, SKILL_COUNT, SOURCE_DIR from Phase 1

check_skills_dir() {
  local label="$1"
  local skills_dir="$2"

  echo "$label: $skills_dir"

  if [ ! -d "$skills_dir" ]; then
    _fail "Skills directory does not exist!"
    echo ""
    return
  fi

  local valid=0
  local broken=0
  local wrong_target=0
  local missing_list=""
  local thirdparty_list=""
  local standalone_files_list=""
  local standalone_dirs_list=""
  local alias_list=""

  # ── Check each expected canonical skill ──
  for skill in $SOURCE_SKILL_LIST; do
    local entry="$skills_dir/$skill"

    if [ ! -e "$entry" ] && [ ! -L "$entry" ]; then
      # Not present at all
      missing_list="$missing_list $skill"
    elif [ -L "$entry" ]; then
      if [ ! -e "$entry" ]; then
        # Broken symlink
        broken=$((broken + 1))
      else
        # Valid symlink — check target
        local target
        target=$(readlink "$entry")
        local expected_target="$SOURCE_DIR/$skill"
        if [ "$target" = "$expected_target" ]; then
          valid=$((valid + 1))
        else
          # Try resolving relative symlink
          local resolved=""
          if [ -d "$(dirname "$skills_dir/$target")" ]; then
            resolved=$(cd "$skills_dir" && cd "$(dirname "$target")" 2>/dev/null && echo "$(pwd)/$(basename "$target")") || true
          fi
          if [ "$resolved" = "$expected_target" ]; then
            valid=$((valid + 1))
          else
            wrong_target=$((wrong_target + 1))
          fi
        fi
      fi
    elif [ -d "$entry" ]; then
      standalone_dirs_list="$standalone_dirs_list $skill"
    fi
  done

  # ── Check for extra entries not in source ──
  for entry in "$skills_dir"/*; do
    # Skip if glob didn't match
    [ ! -e "$entry" ] && [ ! -L "$entry" ] && continue
    local name
    name=$(basename "$entry")
    [ "$name" = ".DS_Store" ] && continue

    # Skip canonical skills (already checked above)
    in_list "$name" "$SOURCE_SKILL_LIST" && continue

    # Classify the extra
    if [ -L "$entry" ]; then
      local target
      target=$(readlink "$entry")
      if [ ! -e "$entry" ]; then
        broken=$((broken + 1))
      elif echo "$target" | grep -q '\.agents'; then
        thirdparty_list="$thirdparty_list $name"
      elif echo "$target" | grep -q "$SOURCE_DIR"; then
        # Points to source but with a different name = alias
        alias_list="$alias_list $name"
      else
        _info "extra symlink: $name -> $target"
      fi
    elif [ -f "$entry" ]; then
      standalone_files_list="$standalone_files_list $name"
    elif [ -d "$entry" ]; then
      standalone_dirs_list="$standalone_dirs_list $name"
    fi
  done

  # Note: broken symlinks are already caught above.
  # In bash, globs expand to include broken symlinks as directory entries,
  # and our check ([ ! -e ] && [ ! -L ]) does NOT skip symlinks,
  # so broken symlinks are processed in both loops above.

  # ── Trim leading spaces ──
  missing_list="${missing_list# }"
  thirdparty_list="${thirdparty_list# }"
  standalone_files_list="${standalone_files_list# }"
  standalone_dirs_list="${standalone_dirs_list# }"
  alias_list="${alias_list# }"

  # ── Report ──
  if [ "$valid" -eq "$SKILL_COUNT" ]; then
    _pass "$valid canonical symlinks valid"
  elif [ "$valid" -gt 0 ]; then
    _warn "$valid/$SKILL_COUNT canonical symlinks valid"
  else
    _fail "0/$SKILL_COUNT canonical symlinks valid"
  fi

  if [ -n "$missing_list" ]; then
    local mc=0; for _ in $missing_list; do mc=$((mc + 1)); done
    _fail "$mc missing: $missing_list"
  fi
  [ "$broken" -gt 0 ] && _fail "$broken broken symlinks"
  [ "$wrong_target" -gt 0 ] && _warn "$wrong_target symlinks point to wrong target"
  if [ -n "$thirdparty_list" ]; then
    local tc=0; for _ in $thirdparty_list; do tc=$((tc + 1)); done
    _info "$tc third-party skills ($thirdparty_list)"
  fi
  if [ -n "$alias_list" ]; then
    local ac=0; for _ in $alias_list; do ac=$((ac + 1)); done
    _info "$ac aliases ($alias_list)"
  fi
  if [ -n "$standalone_files_list" ]; then
    local fc=0; for _ in $standalone_files_list; do fc=$((fc + 1)); done
    _info "$fc standalone files ($standalone_files_list)"
  fi
  if [ -n "$standalone_dirs_list" ]; then
    local dc=0; for _ in $standalone_dirs_list; do dc=$((dc + 1)); done
    _info "$dc standalone dirs ($standalone_dirs_list)"
  fi
  echo ""
}

# ══════════════════════════════════════════════════════════════
# PHASE 2: Claude Code Skills
# ══════════════════════════════════════════════════════════════

check_skills_dir "Claude Code" "$CLAUDE_SKILLS"

# ══════════════════════════════════════════════════════════════
# PHASE 3: OpenCode Skills
# ══════════════════════════════════════════════════════════════

check_skills_dir "OpenCode" "$OPENCODE_SKILLS"

# ══════════════════════════════════════════════════════════════
# PHASE 4: Manifest Check (optional)
# ══════════════════════════════════════════════════════════════

echo "Manifest: $MANIFEST"

if [ ! -f "$MANIFEST" ]; then
  _info "No manifest found (filesystem-only mode)"
else
  # Manifest exists — compare entries against filesystem
  if command -v jq >/dev/null 2>&1; then
    # Get canonical skills from manifest (source path contains the canonical source dir)
    manifest_canonical=$(jq -r --arg src "Documents/metaprompts/_skills" \
      '.items[]? | select(.type == "skill" and (.status != "deprecated" and .status != "archived") and (.source.path | contains($src))) | .id' \
      "$MANIFEST" 2>/dev/null | tr '\n' ' ' | sed 's/ $//' || echo "")
    # Get third-party skills from manifest
    manifest_thirdparty=$(jq -r --arg src "Documents/metaprompts/_skills" \
      '.items[]? | select(.type == "skill" and (.status != "deprecated" and .status != "archived") and (.source.path | contains($src) | not)) | .id' \
      "$MANIFEST" 2>/dev/null | tr '\n' ' ' | sed 's/ $//' || echo "")

    manifest_total=0
    for _ in $manifest_canonical $manifest_thirdparty; do manifest_total=$((manifest_total + 1)); done

    if [ "$manifest_total" -eq 0 ]; then
      _warn "Manifest exists but couldn't parse skills from it"
    else
      issues=0

      # Check: canonical manifest entries present on disk?
      for skill in $manifest_canonical; do
        if [ ! -d "$SOURCE_DIR/$skill" ]; then
          _warn "In manifest but missing from source: $skill"
          issues=$((issues + 1))
        fi
      done

      # Check: source skills present in manifest?
      for skill in $SOURCE_SKILL_LIST; do
        if [ -n "$manifest_canonical" ] && ! in_list "$skill" "$manifest_canonical"; then
          _warn "On disk but not in manifest: $skill"
          issues=$((issues + 1))
        fi
      done

      # Report third-party skills found in manifest
      if [ -n "$manifest_thirdparty" ]; then
        tp_count=0; for _ in $manifest_thirdparty; do tp_count=$((tp_count + 1)); done
        _info "$tp_count third-party skills in manifest ($manifest_thirdparty)"
      fi

      if [ "$issues" -eq 0 ]; then
        canon_count=0; for _ in $manifest_canonical; do canon_count=$((canon_count + 1)); done
        _pass "Manifest in sync ($canon_count canonical skills)"
      fi
    fi
  else
    _warn "jq not available — cannot parse manifest"
  fi
fi
echo ""

# ══════════════════════════════════════════════════════════════
# PHASE 5: Config Files
# ══════════════════════════════════════════════════════════════

echo "Config Files:"

# Check CLAUDE.md
if [ -f "$CLAUDE_CONFIG" ]; then
  _pass "CLAUDE.md exists ($(wc -l < "$CLAUDE_CONFIG" | tr -d ' ') lines)"
else
  _fail "CLAUDE.md not found at $CLAUDE_CONFIG"
fi

# Check AGENTS.md
if [ -f "$OPENCODE_CONFIG" ]; then
  _pass "AGENTS.md exists ($(wc -l < "$OPENCODE_CONFIG" | tr -d ' ') lines)"

  # Basic sanity: check skills path reference
  if grep -q '\.config/opencode/skills' "$OPENCODE_CONFIG"; then
    _pass "AGENTS.md references correct skills path"
  elif grep -q 'skills' "$OPENCODE_CONFIG"; then
    # Check for wrong path references
    wrong_path=$(grep -o '~/\.[a-zA-Z/]*skills[a-zA-Z/]*' "$OPENCODE_CONFIG" | head -1)
    if [ -n "$wrong_path" ]; then
      _warn "AGENTS.md references skills path: $wrong_path (expected ~/.config/opencode/skills)"
    fi
  fi
else
  _fail "AGENTS.md not found at $OPENCODE_CONFIG"
fi
echo ""

# ══════════════════════════════════════════════════════════════
# PHASE 6: Hooks
# ══════════════════════════════════════════════════════════════

echo "Hooks: $CLAUDE_HOOKS"

if [ ! -d "$CLAUDE_HOOKS" ]; then
  _warn "Hooks directory does not exist"
else
  hook_count=0
  for hook in "$CLAUDE_HOOKS"/*; do
    [ ! -f "$hook" ] && continue
    name=$(basename "$hook")
    [ "$name" = ".DS_Store" ] && continue
    hook_count=$((hook_count + 1))
    if [ -x "$hook" ]; then
      _pass "Hook: $name (executable)"
    else
      _warn "Hook: $name (not executable!)"
    fi
  done

  if [ "$hook_count" -eq 0 ]; then
    _info "No hooks found"
  fi

  # Check if hooks are registered in settings.json
  if [ -f "$CLAUDE_SETTINGS" ] && command -v jq >/dev/null 2>&1; then
    registered=$(jq -r '.hooks | keys[]' "$CLAUDE_SETTINGS" 2>/dev/null || echo "")
    if [ -n "$registered" ]; then
      _info "Registered hook triggers: $registered"
    fi
  fi
fi
echo ""

# ══════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════

echo "───────────────────────────────────"
echo "  Summary"
echo "───────────────────────────────────"
echo "  $PASS_COUNT passed, $WARN_COUNT warnings, $FAIL_COUNT failures"
echo "───────────────────────────────────"
echo ""

# ── Exit code ────────────────────────────────────────────────
if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 2
elif [ "$WARN_COUNT" -gt 0 ]; then
  exit 1
else
  exit 0
fi
