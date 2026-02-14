# Roux System Walkthrough

> A complete guide to JRG's agentic ecosystem as of February 2026.
> This document covers architecture, day-to-day usage, verification,
> content strategy, and session notes.

---

## Session Summary

This document was produced at the end of a multi-session consolidation effort (Feb 12–14, 2026) that audited, classified, and cleaned up JRG's agentic tool ecosystem.

**What happened:** Starting from 46+ skills scattered across 5 AI coding tools (Claude Code, OpenCode, Intent/Augment, Auggie CLI, OMP CLI), the session discovered 29 broken symlinks in OpenCode, stale config claiming 42 skills when only 21 were real, an empty SQLite database, and zero skill configuration in OMP. The root cause was that skills were being managed per-tool with no cross-tool awareness — deprecating skills in the source directory didn't propagate to all consumers.

**What was built:** A classification framework called "Roux" (8 Dimensions × Scope × Agency) that assigns every piece of AI configuration a triple describing what concern it addresses, where it lives, and who triggers it. This was operationalized into two personal tools: `~/.roux/manifest.json` (a routing table mapping 34 items across 5 tools) and `~/.roux/verify.sh` (a 419-line bash+jq checker that validates the filesystem against the manifest). Waves A and B of the recommendations were executed: broken symlinks cleaned, AGENTS.md fixed, `~/.roux/` created and git-initialized, manifest generated, checker written and debugged.

**Key decision (Path A):** Build personal tooling now. Publish the Roux framework as content later. Open-source CLI only if the write-up generates demand. Get back to building apps.

### Session Specifics

- **32 recommendations produced** across 5 waves (A–E), each individually approvable
- **Waves A+B executed:** 4 P0 fixes + 4 P1 foundation items = 8 tasks completed
- **Waves C–E remain:** cross-tool sync (R08–R13), promotions & merges (R14–R24), future work (R26–R32)
- **First verify run: 8 passed, 0 warnings, 0 failures**
- **Manifest: 34 items** — 21 canonical skills, 3 third-party, 1 hook, 3 commands, 2 config fragments, assorted non-skill items
- **Artifacts location:** all planning in Intent workspace notes (fancy-fowl), all operational files in `~/.roux/`
- **Git branch:** `roux-consolidation-planning` (workspace repo); `~/.roux/` has its own git repo

---

## Architecture Overview

```
                        ┌──────────────────────────┐
                        │   Source of Truth         │
                        │   ~/Documents/metaprompts │
                        │   └── _skills/ (21)       │
                        │   └── _deprecated/ (26)   │
                        │   └── _workflows/         │
                        │   └── _logs/              │
                        └────────────┬─────────────┘
                                     │ symlinks
              ┌──────────────────────┼──────────────────────┐
              ▼                      ▼                      ▼
   ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
   │   Claude Code    │   │    OpenCode      │   │  Intent/Augment  │
   │   ~/.claude/     │   │  ~/.config/      │   │  ~/.augment/     │
   │                  │   │   opencode/      │   │                  │
   │  skills/ (25)    │   │  skills/ (22)    │   │  skills/ (2 3rd) │
   │  commands/ (3)   │   │  command/ (1)    │   │  reads_from:     │
   │  hooks/ (1)      │   │  (no hooks)      │   │   └── claude     │
   │  CLAUDE.md       │   │  AGENTS.md       │   │                  │
   │  settings.json   │   │  opencode.json   │   │  settings.json   │
   └──────────────────┘   └──────────────────┘   └──────────────────┘
           │                                              │
           ▼                                              ▼
   ┌──────────────────┐                        ┌──────────────────┐
   │  OMP CLI         │                        │  Auggie CLI      │
   │  ~/.omp/         │                        │  (via Augment    │
   │  0 skills        │                        │   platform)      │
   │  has --skills    │                        │  reads_from:     │
   │  flag but unused │                        │   └── claude     │
   └──────────────────┘                        └──────────────────┘

              ┌──────────────────────────────┐
              │   ~/.roux/ (Roux Hub)        │
              │   manifest.json (34 items)   │
              │   verify.sh (419 lines)      │
              │   .git/ (version tracked)    │
              └──────────────────────────────┘

              ┌──────────────────────────────┐
              │   ~/.agents/ (Third-Party)   │
              │   .skill-lock.json           │
              │   skills/find-skills         │
              │   skills/playwriter          │
              │   skills/refactor (awesome-  │
              │          copilot, unused)    │
              └──────────────────────────────┘
```

### Key Relationships

- **Claude is the hub.** Intent/Augment and Auggie read from Claude's skills dir via relative paths. Fix Claude → fix 3 tools.
- **OpenCode is independent.** Its own symlinks to the same source. Must be updated separately.
- **OMP is unconfigured.** Has the flags but zero skills. Future work.
- **Third-party skills** are managed by `.skill-lock.json` and live in `~/.agents/`.

---

## The 8 Dimensions of Roux

Every piece of AI configuration has a **Roux triple**: (Dimension × Scope × Agency). The dimension says *what concern* the item addresses.

### 1. Knowledge

**What it is:** Domain expertise the agent wouldn't otherwise have.
**Natural mechanism:** Rules (CLAUDE.md sections), always-on context.
**Your items:**

| Item | Scope | Agency | Current Mechanism | Notes |
|------|-------|--------|-------------------|-------|
| building-with-solidjs | Session | Agent | Skill | Correct — loaded on-demand for SolidJS work |
| building-with-solidstart | Session | Agent | Skill | Correct — loaded on-demand |
| backend-first-security | Session | Agent | Skill | Correct — loaded for Supabase/Next.js |
| debugging-with-logs | Session | Agent | Skill | Correct — canonical log line patterns |
| designing-apis | Session | Agent | Skill | Correct — REST API design principles |
| security-checklist | Session | Agent | Skill | Correct — VPS hardening checklist |
| self-hosting-vps-ubuntu | Session | Agent | Skill | Correct — Ubuntu server setup |
| timestamp-protocol | Global | Agent | **Skill (WRONG)** | **Pending promotion → rule in CLAUDE.md (R14)** |

**Action needed:** `timestamp-protocol` is always-on context ("begin each message with current date") — it should be a 1-line rule, not a loadable skill. Already in CLAUDE.md as the "Temporal Anchoring" section, so effectively promoted already. Just need to remove the skill.

### 2. Capability

**What it is:** Tools, integrations, and extensions that give the agent new abilities.
**Natural mechanism:** MCP servers, plugins, tool configurations.
**Your items:**

| Item | Scope | Agency | Current Mechanism |
|------|-------|--------|-------------------|
| find-skills | Global | Agent | Third-party skill (vercel-labs) |
| playwriter | Global | Agent | Third-party skill (remorses) |

**Note:** These are correctly categorized — they extend what the agent can *do*, not what it *knows*.

### 3. Behavior

**What it is:** Rules about *how* the agent acts — triggers, guards, constraints.
**Natural mechanism:** Hooks (system-triggered automation).
**Your items:**

| Item | Scope | Agency | Current Mechanism | Notes |
|------|-------|--------|-------------------|-------|
| skill-router | Global | System | Hook (UserPromptSubmit) | **Correct** — fires automatically |
| ending-session | Global | System | **Skill (WRONG)** | **Pending → Stop hook (R15)** |
| starting-session | Global | System | **Skill (WRONG)** | **Pending → SessionStart hook (R16)** |
| fresh-eyes-review | Session | System | **Skill (WRONG)** | **Pending → PostToolUse hook (R17)** |
| refactoring-framework | Session | System | **Skill (WRONG)** | **Pending → PreToolUse hook (R18)** |

**Action needed:** 4 skills are misclassified as on-demand (Composition) when they should be system-triggered (Behavior). Each needs promotion to a hook. This is Wave D work.

### 4. Composition

**What it is:** Reusable patterns, templates, and workflows invoked on-demand.
**Natural mechanism:** Skills (SKILL.md) and commands (slash commands).
**Your items:**

| Item | Scope | Agency | Current Mechanism | Notes |
|------|-------|--------|-------------------|-------|
| session-mining | Session | Agent | Skill | Correct |
| metaprompt-process | Session | Agent | Skill | Correct (undecided — keep/rename?) |
| prd | Session | Agent | Skill | **Pending merge with project-documentation (R21)** |
| project-documentation | Session | Agent | Skill | **Pending merge with prd (R21)** |
| refactor | Session | Agent | Skill | **Pending merge with refactoring-framework (R19)** |
| evaluating-product-ideas | Session | Agent | Skill | **Pending merge with evaluating-business-strategy (R20)** |
| evaluating-business-strategy | Session | Agent | Skill | **Pending merge (R20)** |
| cognitive-approaches | Session | Agent | Skill | **Pending merge with meta-agent-template (R22)** |
| meta-agent-template | Session | Agent | Skill | **Pending merge (R22)** |
| config-wizard | Session | Agent | Command | Correct |
| download-docs | Session | Agent | Command | Correct |
| rams | Session | Agent | Command | Correct (undecided — keep/deprecate?) |

**Action needed:** 4 merge pairs are pending (Wave D). After merges, Composition drops from 12 items to ~8.

### 5. Delegation

**What it is:** How work gets handed off to sub-agents.
**Natural mechanism:** Agent configs (`.claude/agents/*.md`).
**Your items:** None currently. Future: if you create scoped agent personas.

### 6. Interaction

**What it is:** How the agent communicates with the human.
**Natural mechanism:** Config fragments shared across tools.
**Your items:**

| Item | Tools | Current Mechanism |
|------|-------|-------------------|
| ASCII Task Shape Protocol | Claude, OpenCode | Config fragment (identical in both) |

### 7. Sustain

**What it is:** Token budget, context management, compaction settings.
**Natural mechanism:** Config entries (settings.json).
**Your items:** No explicit items yet. Implicit in `settings.json` model configs.

### 8. Environment

**What it is:** Terminal, editor, tool-specific configuration.
**Natural mechanism:** Config entries, tool settings.
**Your items:**

| Item | Tools | Current Mechanism |
|------|-------|-------------------|
| Git conventions | Claude, OpenCode | Config fragment (`gitas claude commit` / `gitas opencode commit`) |

---

## Day-to-Day Usage

### Starting a Session

1. **Automatic:** The `skill-router` hook fires on every user prompt (Claude Code only). It scans `~/.claude/skills/`, matches skill descriptions against your prompt, and suggests relevant ones.
2. **Manual:** Type `/starting-session` to read NEXT_STEPS.md from the current directory.
3. **Verification:** Run `bash ~/.roux/verify.sh` to check ecosystem health (takes <2 seconds).

### During a Session

- **Skills load on-demand.** The skill-router suggests them, or you invoke directly (e.g., `/refactor`, `/prd`).
- **Rules are always-on.** Everything in CLAUDE.md is in context for every turn (task protocol, git conventions, temporal anchoring).
- **Hooks fire automatically.** Currently only `skill-router.sh` on UserPromptSubmit.

### Adding a New Skill

```bash
# 1. Create the skill in the source of truth
mkdir ~/Documents/metaprompts/_skills/my-new-skill
# Write SKILL.md with frontmatter (name, description, etc.)

# 2. Symlink to each tool that should see it
ln -s ~/Documents/metaprompts/_skills/my-new-skill ~/.claude/skills/my-new-skill
ln -s ~/Documents/metaprompts/_skills/my-new-skill ~/.config/opencode/skills/my-new-skill

# 3. Update the manifest
# Edit ~/.roux/manifest.json — add an item entry with roux triple

# 4. Verify
bash ~/.roux/verify.sh

# 5. Commit
cd ~/.roux && git add manifest.json && git commit -m "Add my-new-skill"
```

### Deprecating a Skill

```bash
# 1. Move to deprecated
mv ~/Documents/metaprompts/_skills/old-skill ~/Documents/metaprompts/_skills/_deprecated/old-skill

# 2. Remove symlinks from all tools
rm ~/.claude/skills/old-skill
rm ~/.config/opencode/skills/old-skill

# 3. Update manifest — set status: "deprecated"

# 4. Verify (should show no broken links)
bash ~/.roux/verify.sh
```

### Promoting a Skill to a Hook

This is the "gravity" pattern — moving something from on-demand (Composition) to automatic (Behavior):

```bash
# 1. Write the hook script
# ~/.claude/hooks/my-hook.sh

# 2. Register in settings.json
# Add to hooks.{EventType} array

# 3. Deprecate the skill (steps above)

# 4. Update manifest — change type from "skill" to "hook", dimension to "Behavior"
```

### Promoting a Skill to a Rule

Moving from on-demand to always-on:

```bash
# 1. Add the content to CLAUDE.md (and AGENTS.md if shared)
# 2. Deprecate the skill
# 3. Update manifest — change type to "rule", dimension to "Knowledge"
```

### Processing New Content (Skills, Fragments, Ideas)

When you encounter a new pattern, technique, or prompt fragment:

1. **Classify it** with a Roux triple: What dimension? What scope? What agency?
2. **Route it** to the correct mechanism based on the Dimension → Mechanism mapping:
   - Knowledge → rule (CLAUDE.md section)
   - Behavior → hook (script + settings.json)
   - Composition → skill (SKILL.md in source dir)
   - Capability → tool/MCP integration
3. **Place it** in the source of truth (`~/Documents/metaprompts/_skills/` for skills)
4. **Propagate** via symlinks to consumer tools
5. **Manifest** — add to `~/.roux/manifest.json`
6. **Verify** — run `bash ~/.roux/verify.sh`

### The Gravity Test

Ask these questions about any piece of configuration:

- **Does it fire every time?** → It should be a hook or rule, not a skill.
- **Does it need the full session context?** → Skill is correct.
- **Does it need human invocation?** → Command is correct.
- **Is it domain knowledge the agent lacks?** → Knowledge rule or skill.
- **Is it a behavioral constraint?** → Hook (system-triggered).

If something is in the wrong slot, it's costing you either:
- **Token waste** (global context for something session-specific)
- **Friction** (manual invocation for something that should be automatic)
- **Silent absence** (automatic thing configured as on-demand, so it never fires)

---

## Verification & Observability

### Current: verify.sh

```bash
bash ~/.roux/verify.sh           # Full check, human-readable
bash ~/.roux/verify.sh --fixes   # Show fix recommendations
bash ~/.roux/verify.sh --json    # Machine-parseable output
```

**What it checks (6 phases):**
1. Source directory — all 21 skills have SKILL.md
2. Per-tool symlink health — Claude and OpenCode skills dirs
3. Manifest sync — items match filesystem
4. Config files — CLAUDE.md and AGENTS.md exist
5. Hooks — skill-router.sh present and executable
6. Extra/orphan detection — standalone files, unknown items

**Current result:** 8 passed, 0 warnings, 0 failures.

### How Do You Know Skills Are Being Used?

This is the key open question. Options:

#### Option A: Omni Event Logging (Recommended)

Install `omni` globally (R26) and create a `roux.skill.loaded` event type:

```bash
# In skill-router.sh, after suggesting a skill:
omni event push --type roux.skill.loaded --data '{"skill":"building-with-solidjs","trigger":"auto"}'

# Query later:
omni event list --type roux.skill.loaded --since 7d
```

**Pros:** Structured, queryable, no file clutter in repos.
**Cons:** Requires omni to be installed and working. Currently omni was in /tmp/ and lost.

#### Option B: Append-Only roux.log (Lightweight Alternative)

Create `~/.roux/roux.log` as an append-only log:

```bash
# In skill-router.sh:
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) LOADED building-with-solidjs auto" >> ~/.roux/roux.log

# In verify.sh (on each run):
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) VERIFY 8-pass 0-warn 0-fail" >> ~/.roux/roux.log

# Query:
grep "LOADED" ~/.roux/roux.log | sort | uniq -c | sort -rn  # Most-used skills
grep "2026-02" ~/.roux/roux.log | wc -l  # Activity this month
```

**Pros:** Zero dependencies, works today, simple grep/awk analysis.
**Cons:** Unstructured, grows unbounded, no dashboard.

#### Option C: Per-Repo roux.log (Discovery Signal)

Drop a `.roux.log` in each project repo (gitignored):

```bash
# In skill-router.sh, if in a git repo:
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) LOADED building-with-solidjs" >> "$(git rev-parse --show-toplevel)/.roux.log" 2>/dev/null

# See which skills are used in this project:
cat .roux.log | grep LOADED | awk '{print $3}' | sort | uniq -c | sort -rn
```

**Pros:** Per-project skill usage data. "This project uses SolidJS skill heavily."
**Cons:** File management across repos. Needs gitignore entry.

#### Recommended: Start with Option B, Add Option A Later

1. **Now:** Add append to `~/.roux/roux.log` in `skill-router.sh` (5-minute change)
2. **Later:** When omni is installed (R26), pipe logs to omni events
3. **Optional:** Add per-repo `.roux.log` if you want project-level visibility

### Should You Install Omni Globally?

**Yes, eventually.** Omni is the right long-term answer for observability — structured events, queryable, dashboard-ready. But it's R26 (P3, Wave E). Don't block on it.

**For now:** `~/.roux/roux.log` + `verify.sh` gives you 80% of the value with zero dependencies.

### Enforcing Omni as a Dimension

If you want omni to be a first-class part of the Roux system:

```json
// In manifest.json, add:
{
  "id": "omni",
  "type": "tool",
  "name": "Omni Event System",
  "description": "Observability layer for roux — structured event logging",
  "source": { "path": "~/omni/" },
  "roux": {
    "dimension": "Sustain",
    "scope": "Global",
    "agency": "System"
  },
  "status": "pending_install",
  "consumers": {
    "claude": { "method": "config_entry", "key": "PATH includes omni" },
    "opencode": null,
    "intent": null,
    "auggie": null,
    "omp": null
  }
}
```

This makes omni visible to the checker — it'll flag "omni: not installed" until you set it up.

---

## What Was Created (Complete Inventory)

### Files on Disk

| Path | Size | Purpose |
|------|------|---------|
| `~/.roux/manifest.json` | 39KB, 1333 lines | Routing table — 34 items × 5 tools |
| `~/.roux/verify.sh` | 17KB, 419 lines | 6-phase consistency checker |
| `~/.roux/.git/` | — | Version tracking for roux files |

### What Was Fixed

| Action | Detail |
|--------|--------|
| Removed 29 broken symlinks | OpenCode `~/.config/opencode/skills/` — all deprecated skills |
| Fixed AGENTS.md skill count | 42 → 21 |
| Fixed AGENTS.md skills path | `~/.config/agents/skills/` → `~/.config/opencode/skills/` |
| Deleted empty SQLite | `~/cortex/omni_db_2026-02-12.sqlite` (4KB, no tables) |

### What Remains (Waves C–E)

**Wave C — Cross-Tool Sync (~55 min):**
- R08: Sync 2 missing commands to OpenCode
- R09: Resolve sigiling-inbox alias
- R10: Remove 3 standalone .md files from skills dirs
- R11: Remove theme-sync dirs from skills dirs
- R12: Sync CLAUDE.md ↔ AGENTS.md shared sections
- R13: Decide on metaprompt-process and rams

**Wave D — Promotions & Merges (~5 hours, multiple sittings):**
- R14: `timestamp-protocol` → rule in CLAUDE.md
- R15–R16: `ending-session` → Stop hook, `starting-session` → SessionStart hook
- R17–R18: `fresh-eyes-review` → PostToolUse hook, `refactoring-framework` → PreToolUse hook
- R19: Merge `refactor` + `refactoring-framework`
- R20–R22: 3 more merges (eval skills, prd+docs, meta+cognitive)
- R23–R24: Archive cortex files

**Wave E — Future (hours to days):**
- R26: Install omni persistently
- R27: Investigate OMP skill discovery
- R28: Run full 46-skill roux evaluation
- R29: Classify 80+ extracted fragments
- R30: Consolidate workspace locations
- R31: Implement 5 metaprompt v2 upgrades
- R32: Write up roux for publication

---

## Current State by Tool

### Claude Code — Hub (Healthy)

```
~/.claude/
├── skills/          25 entries (21 canonical + 2 third-party + extras)
├── commands/        3 files (config-wizard, download-docs, rams)
├── hooks/           1 file (skill-router.sh, UserPromptSubmit)
├── CLAUDE.md        102 lines — rules, conventions, task protocol
└── settings.json    Model config, hook registration, permissions
```

**Status:** All green. Primary hub for the ecosystem.

### OpenCode — Mirror (Healthy, was broken)

```
~/.config/opencode/
├── skills/          22 entries (21 canonical + 1 alias)  ← was 51 (29 broken)
├── command/         1 file (rams)                        ← missing 2 commands
├── AGENTS.md        584 lines — includes Anima system    ← fixed count/path
└── opencode.json    Provider/model config
```

**Status:** Clean after Wave A fixes. Missing 2 commands (Wave C).

### Intent/Augment — Parasite (Works via Claude)

```
~/.augment/
├── skills/          2 entries (third-party only)
├── rules/           1 entry (refactor symlink, unclear purpose)
├── settings.json    Indexing config
└── sessions/        92+ session directories
```

**Status:** Reads from `~/.claude/skills/` via relative path. Fragile but functional.

### Auggie CLI — Platform (Works via Augment)

**Status:** No native skill directory. Everything via the Augment platform.

### OMP CLI — Blank Slate

```
~/.omp/
└── agent/
    ├── config.yml   Model roles only
    ├── *.sqlite     Session databases
    └── (no skills dir)
```

**Status:** Has `--skills` flag but zero configuration. Needs investigation (R27).

---

## Content Angles for Roux (Publishing Strategy)

The following 5 content angles were developed from the consolidation journey. Each can stand alone. Together they tell the story: chaos → audit → framework → restraint.

### Recommended Publishing Order

1. **"Your AI Tools Are Silently Getting Dumber"** (Angle 3)
   - *Hook:* "29 of my AI coding skills were broken and I didn't notice for two weeks."
   - *Format:* X thread (8–10 tweets), ~1,000 words
   - *Why first:* Fastest to write, most actionable, "go check yours now" CTA drives engagement
   - *Key beats:* The discovery moment, why AI tools don't validate configs, the 5-minute audit checklist

2. **"The Meta-Trap"** (Angle 1)
   - *Hook:* "I spent 3 months building tools to manage my AI tools."
   - *Format:* X thread (10–12 tweets) + blog post, ~2,000 words
   - *Why second:* Personal story establishes credibility and relatability
   - *Key beats:* The absurdity ("a bash script to help my AI coding assistant"), the accumulation pattern, the hydra moment, the deliberate decision to stop

3. **"Vibe Coding Has a Config Problem"** (Angle 5)
   - *Hook:* "Everyone's talking about vibe coding quality. Nobody's talking about the config layer."
   - *Format:* X thread (12–15 tweets) + blog, ~2,500 words
   - *Why third:* Rides existing discourse, contrarian enough for discussion
   - *Key beats:* Discourse reframe (generation quality is upstream), the config spectrum (default → rules → skills → routing → verification), "not used ≠ not valuable" insight, SolidJS skill example

4. **"The Broken Ladder"** (Angle 2)
   - *Hook:* "Every AI coding tool has the same five gaps."
   - *Format:* Blog post with parity table as centerpiece, ~2,500 words
   - *Why fourth:* Technical depth piece for the audience that stuck around
   - *Key beats:* The parity table (21 skills × 5 tools), specific failure modes, why it's not a "pick one tool" problem, the cross-tool manifest idea

5. **"The Slime Mold and the Routing Table"** (Angle 4)
   - *Hook:* "The best model for how AI skills should work isn't a pipeline. It's a slime mold."
   - *Format:* Blog post, ~3,000 words
   - *Why last:* Big idea piece — the framework reveal for followers
   - *Key beats:* Slime mold metaphor, gravity rules, 8 dimensions as diagnostic tool, concrete examples (ending-session, timestamp-protocol), why misclassification wastes context

### Voice Notes for All Content

- First person ("I" not "we")
- Specific numbers always ("29 broken symlinks" not "many broken links")
- Self-deprecating about the meta-trap — confessing, not bragging
- No "10 tips" energy — stories with a point
- Target reader: someone with 3+ custom instructions and a nagging feeling it's getting messy

---

## Quick Reference Card

```
# Check ecosystem health
bash ~/.roux/verify.sh

# Check with fix recommendations
bash ~/.roux/verify.sh --fixes

# See what's in the manifest
jq '.items | length' ~/.roux/manifest.json           # Item count
jq '.items[] | .id' ~/.roux/manifest.json             # All item IDs
jq '[.items[] | select(.status == "active")] | length' ~/.roux/manifest.json  # Active count
jq '[.items[] | select(.status | startswith("pending"))]' ~/.roux/manifest.json  # Pending actions

# Find misclassified items (Behavior dimension but Skill type)
jq '.items[] | select(.roux.dimension == "Behavior" and .type == "skill") | .id' ~/.roux/manifest.json

# See what each tool has
ls -la ~/.claude/skills/ | grep "^l" | wc -l          # Claude symlinks
ls -la ~/.config/opencode/skills/ | grep "^l" | wc -l  # OpenCode symlinks

# Check for broken symlinks (should be 0)
find ~/.claude/skills -maxdepth 1 -type l ! -exec test -e {} \; -print
find ~/.config/opencode/skills -maxdepth 1 -type l ! -exec test -e {} \; -print

# Commit manifest changes
cd ~/.roux && git add -A && git commit -m "Update manifest"
```

---

## Open Questions

1. **Omni install:** When to do R26? After current project or as a Wave C add-on?
2. **OMP skills:** What is OMP's actual skill discovery mechanism? (R27)
3. **Per-repo .roux.log:** Worth the complexity or overkill for solo dev?
4. **AGENTS.md bloat:** 584 lines vs CLAUDE.md's 102. Should the Anima/0xA system be trimmed or is it serving OpenCode well?
5. **Merge decisions:** Some merges (R22, meta-agent-template + cognitive-approaches) may not make sense. User to decide during Wave D.
