# Auto-format on save using PostToolUse hooks

**Source:** Twitter thread by @affaanmustafa
**Captured:** 2026-02-06
**Raw notes:** Saw this pattern for auto-running prettier after every edit. Could replace my manual formatting step.

---

Instead of telling Claude "always format your code" in CLAUDE.md (which wastes context and Claude sometimes forgets), use a PostToolUse hook:

```json
{
  "PostToolUse": [{
    "matcher": "tool == 'Edit' && tool_input.file_path matches '\\.(ts|tsx|js|jsx)$'",
    "hooks": [{
      "type": "command",
      "command": "npx prettier --write \"$TOOL_INPUT_FILE_PATH\""
    }]
  }]
}
```

Zero context cost. 100% reliable. The agent doesn't even need to know about formatting — it happens automatically at the system level.
