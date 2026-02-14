# The Shorthand Guide to Everything Agentic

**Origin:** @affaanmustafa | **Purpose:** Classification reference for agentic information

---

## The Classification System

Every piece of agentic information is classified by a triple:

```
(Dimension, Scope, Agency)
    what        where     who
```

Items that produce a clean triple get routed. Items that can't are either noise or craft/conventions material.

---

## Axis 1: Dimension — *What concern does this serve?*

| # | Dimension | Filter Question |
|---|-----------|----------------|
| 1 | **Knowledge** | Does this change what the agent should *know*? |
| 2 | **Capability** | Does this extend what the agent can *reach*? |
| 3 | **Behavior** | Does this automate something the agent should do *without being asked*? |
| 4 | **Composition** | Is this a *reusable pattern* I can invoke by name? |
| 5 | **Delegation** | Can this be *scoped and handed off*? |
| 6 | **Interaction** | Is this a better way to *talk to* the agent? |
| 7 | **Sustain** | Does this help *protect or extend* my session? |
| 8 | **Environment** | Does this improve my *physical workspace*? |

**Hierarchy:** Sustain (7) is the meta-constraint — it governs all other dimensions. Interaction (6) is the multiplier — it amplifies everything else. The remaining six are the substrate.

## Axis 2: Scope — *Where does it live?*

From heaviest (always-on) to lightest (ephemeral):

| Scope | Location | Cost | Example |
|-------|----------|------|---------|
| **Global** | `~/.claude/` | Every session, every project | "Never commit secrets" |
| **Project** | `.claude/` | Every session in this codebase | "Use REST conventions for this API" |
| **Session** | Invoked on-demand | Zero cost until called | `/tdd`, `/security-review` |
| **Ephemeral** | One-time prompt | Gone after the session | "Refactor this function" |

## Axis 3: Agency — *Who consumes it?*

| Consumer | Description | Misroute Example |
|----------|-------------|-----------------|
| **Human** | You change your behavior | Prompting technique put in CLAUDE.md (agent can't use it on itself) |
| **Agent** | Goes into rules, skills, memory | Best practice only in a blog post you never reference |
| **System** | Hooks, CI/CD, automation | Formatting rule as a CLAUDE.md instruction instead of a PostToolUse hook |

---

## Gravity Rules

The binchotan principles that govern placement:

```
Scope gravity     Push everything to the lowest scope level that still works.
Agency routing    Route to the correct consumer. Misrouted information is waste.
Dimension purity  One dimension per item. If it spans two, note the tension.
```

---

## Portable Schema

Drop this anywhere — Sigil analysis, inbox processor, any future tool:

```
DIMENSIONS: Knowledge | Capability | Behavior | Composition | Delegation | Interaction | Sustain | Environment
SCOPE:      Global → Project → Session → Ephemeral (push to lightest)
AGENCY:     Human | Agent | System (route to correct consumer)
CLASSIFY:   (Dimension, Scope, Agency)
ROUTE:      Clean triple → fold into existing. No triple → noise or conventions.
```

---

## Agent Directives

One imperative per dimension. The signal, distilled:

```
1. Knowledge     Only persist what's needed every session.
2. Capability    Enable per-project, not globally.
3. Behavior      If it can be a hook, it shouldn't be a rule.
4. Composition   Name it, scope it, invoke it.
5. Delegation    Isolate context, return summaries.
6. Interaction   Specify success criteria, not vibes.
7. Sustain       Budget tokens like money.
8. Environment   Reduce friction between tools.
```

---

## Cross-Dimension Tensions

Dimensions aren't independent. Optimizing one can degrade another:

```
Capability ←→ Sustain      More tools = less context headroom.
Knowledge  ←→ Sustain      More rules = less session budget.
Composition ←→ Knowledge   Skills are deferred rules. Move rarely-used knowledge to skills.
Delegation ←→ Capability   Background agents can't use MCPs.
Behavior   ←→ Knowledge    Hooks are zero-cost automation. Rules that enforce behavior should be hooks.
```

---

## Anti-Patterns

What to reject, per dimension:

```
1. Knowledge     Don't put project-specific instructions in user-level CLAUDE.md.
2. Capability    Don't leave all MCPs enabled across all projects.
3. Behavior      Don't use rules for things hooks can enforce.
4. Composition   Don't write one-off prompts when you'll use them again.
5. Delegation    Don't dump verbose investigation into main context.
6. Interaction   Don't say "build X" without success criteria.
7. Sustain       Don't ignore context usage until sessions degrade.
8. Environment   Don't fight your terminal — configure it once properly.
```

---

---

## 1. Knowledge

> *Does this change what the agent should know?*
>
> **Directive:** Only persist what's needed every session.

### [Rules](https://opencode.ai/docs/rules/)

**Set custom instructions for opencode.**

You can provide custom instructions to opencode by creating an `AGENTS.md` file. This is similar to Cursor's rules. It contains instructions that will be included in the LLM's context to customize its behavior for your specific project.

### Rules and Memory

Your `.rules` folder holds `.md` files with best practices Claude should ALWAYS follow. Two approaches:

1. **Single CLAUDE.md** - Everything in one file (user or project level) [AGENTS.md file adopted by most other providers/models]
2. **Rules folder** - Modular `.md` files grouped by concern

```bash
~/.claude/rules/
  security.md      # No hardcoded secrets, validate inputs
  coding-style.md  # Immutability, file organization
  testing.md       # TDD workflow, 80% coverage
  git-workflow.md  # Commit format, PR process
  agents.md        # When to delegate to subagents
  performance.md   # Model selection, context management
```

**Example rules:**

- No emojis in codebase
- Refrain from purple hues in frontend
- Always test code before deployment
- Prioritize modular code over mega-files
- Never commit console.logs

### Path-Specific Rules

Rules can be scoped to specific files using frontmatter:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---

# API Development Rules
- All API endpoints must include input validation
- Use standard error response format
```

### Memory Hierarchy

Highest to lowest precedence:

1. Managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md`)
2. Project memory (`./CLAUDE.md` or `./.claude/CLAUDE.md`)
3. Project rules (`./.claude/rules/*.md`)
4. User memory (`~/.claude/CLAUDE.md`)
5. Project memory local (`./CLAUDE.local.md`)

Import other files: `@README`, `@docs/git-instructions.md`, `@~/.claude/my-instructions.md`

**Key insight:** Knowledge is always-on context. Everything here costs tokens every session. If it's not needed every session, it belongs in Composition (dimension 4) instead — loaded on demand.

---

## 2. Capability

> *Does this extend what the agent can reach?*
>
> **Directive:** Enable per-project, not globally.

### [Tools](https://opencode.ai/docs/tools/)

Tools allow the LLM to perform actions in your codebase. OpenCode comes with a set of built-in tools, but you can extend it with custom tools or MCP servers.

By default, all tools are enabled and don't need permission to run. You can control tool behavior through permissions.

### [Custom Tools](https://opencode.ai/docs/custom-tools)

**Create tools the LLM can call in opencode.**

Custom tools are functions you create that the LLM can call during conversations. They work alongside opencode's built-in tools like read, write, and bash.

### [MCP Servers](https://opencode.ai/docs/mcp-servers/)

**Model Context Protocol**

Add local and remote MCP tools.

You can add external tools to OpenCode using the Model Context Protocol, or MCP. OpenCode supports both local and remote servers.

Once added, MCP tools are automatically available to the LLM alongside built-in tools.

MCPs connect Claude to external services directly. Not a replacement for APIs - it's a prompt-driven wrapper around them, allowing more flexibility in navigating information.

**Example:** Supabase MCP lets Claude pull specific data, run SQL directly upstream without copy-paste. Same for databases, deployment platforms, etc.

￼

**Example of the supabase mcp listing the tables within the public schema**

**Chrome in Claude:** is a built-in plugin MCP that lets Claude autonomously control your browser - clicking around to see how things work.

### [Plugins](https://opencode.ai/docs/plugins/)

**Write your own plugins to extend OpenCode.**

Plugins allow you to extend OpenCode by hooking into various events and customizing behavior. You can create plugins to add new features, integrate with external services, or modify OpenCode's default behavior.

### Plugin Load Order

Plugins are loaded from all sources and all hooks run in sequence. The load order is:

1. Global config (`~/.config/opencode/opencode.json`)
2. Project config (`opencode.json`)
3. Global plugin directory (`~/.config/opencode/plugins/`)
4. Project plugin directory (`.opencode/plugins/`)

A plugin is a JavaScript/TypeScript module that exports one or more plugin functions. Each function receives a context object and returns a hooks object.

### The plugin function receives:

- **project:** The current project information
- **directory:** The current working directory
- **worktree:** The git worktree path
- **client:** An opencode SDK client for interacting with the AI
- **$:** Bun's shell API for executing commands

Plugins can subscribe to events.

Plugins package tools for easy installation instead of tedious manual setup. A plugin can be a skill + MCP combined, or hooks/tools bundled together.

￼

**Using /plugins to navigate to MCPs to see which ones are currently installed and their status**

**Rule of thumb:** Have 20-30 MCPs in config, but keep under 10 enabled / under 80 tools active.

### Installing plugins:

```bash
# Add a marketplace
claude plugin marketplace add https://github.com/mixedbread-ai/mgrep

# Open Claude, run /plugins, find new marketplace, install from there
```

￼

**Displaying the newly installed Mixedbread-Grep marketplace**

**LSP Plugins:** are particularly useful if you run Claude Code outside editors frequently. Language Server Protocol gives Claude real-time type checking, go-to-definition, and intelligent completions without needing an IDE open.

```bash
# Enabled plugins example
typescript-lsp@claude-plugins-official  # TypeScript intelligence
pyright-lsp@claude-plugins-official     # Python type checking
hookify@claude-plugins-official         # Create hooks conversationally
mgrep@Mixedbread-Grep                   # Better search than ripgrep
```

Same warning as MCPs - watch your context window.

### Permission Architecture

Capabilities are gated by the allow/deny/ask permission model:

```json
{
  "allow": ["Bash(npm run build)", "Read(~/.zshrc)"],
  "deny": ["Bash(curl *)", "Read(./.env)"],
  "ask": ["Bash(git push *)"]
}
```

**Evaluation order:** deny → ask → allow (first match wins).

**Permission modes:** `default`, `acceptEdits`, `plan`, `dontAsk`, `bypassPermissions`. Cycle live with `Shift+Tab`.

**Key insight:** Every enabled tool/MCP adds its definition to your context window. Capability has a direct cost in dimension 7 (Sustain). Only enable what you actually use per project.

---

## 3. Behavior

> *Does this automate something the agent should do without being asked?*
>
> **Directive:** If it can be a hook, it shouldn't be a rule.

### Hooks

Hooks are trigger-based automations that fire on specific events. Unlike skills, they're constricted to tool calls and lifecycle events.

### Hook Types

1. **PreToolUse** - Before a tool executes (validation, reminders)
2. **PostToolUse** - After a tool finishes (formatting, feedback loops)
3. **UserPromptSubmit** - When you send a message
4. **Stop** - When Claude finishes responding
5. **PreCompact** - Before context compaction
6. **Notification** - Permission requests

Additional lifecycle hooks: `SessionStart`, `SessionEnd`, `SubagentStart`, `SubagentStop`, `PermissionRequest`, `PostToolUseFailure`.

### Hook Types by Execution Model

- **Command hooks** - Run shell scripts (fast, deterministic)
- **Prompt hooks** - Single-turn LLM evaluation (judgment calls)
- **Agent hooks** - Multi-turn tool-using subagent (complex decisions)

### Example: tmux reminder before long-running commands

```json
{
  "PreToolUse": [
    {
      "matcher": "tool == \"Bash\" && tool_input.command matches \"(npm|pnpm|yarn|cargo|pytest)\"",
      "hooks": [
        {
          "type": "command",
          "command": "if [ -z \"$TMUX\" ]; then echo '[Hook] Consider tmux for session persistence' >&2; fi"
        }
      ]
    }
  ]
}
```

￼

**Example of what feedback you get in Claude Code, while running a PostToolUse hook**

**Pro tip:** Use the `hookify` plugin to create hooks conversationally instead of writing JSON manually. Run `/hookify` and describe what you want.

### Exit Codes as Control Flow

- `0` — Success, process output
- `2` — Blocking error (blocks tool call, rejects prompt)
- Other — Non-blocking error (warns but continues)

### Async Hooks

Long-running hooks can run in background without blocking:

```json
{
  "type": "command",
  "command": "/path/to/tests.sh",
  "async": true,
  "timeout": 120
}
```

**Key insight:** Hooks run outside the context window. They're the only automation mechanism that adds zero context cost. Behavior that can be expressed as a hook should be a hook, not a rule.

---

## 4. Composition

> *Is this a reusable pattern I can invoke by name?*
>
> **Directive:** Name it, scope it, invoke it.

### [Skills](https://opencode.ai/docs/skills/)

**Define reusable behavior via SKILL.md definitions**

Agent skills let OpenCode discover reusable instructions from your repo or home directory. Skills are loaded on-demand via the native skill tool—agents see available skills and can load the full content when needed.

Skills operate like rules, constricted to certain scopes and workflows. They're shorthand to prompts when you need to execute a particular workflow.

After a long session of coding you want to clean out dead code and loose .md files? Run `/refactor-clean`. Need testing? `/tdd`, `/e2e`, `/test-coverage`. Skills and commands can be chained together in a single prompt chaining commands together.

￼

I can make a skill that updates codemaps at checkpoints - a way for Claude to quickly navigate your codebase without burning context on exploration. `~/.claude/skills/codemap-updater.md`

### Skill Frontmatter

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true   # Prevent auto-triggering
context: fork                     # Run in subagent
model: opus                       # Model for forked execution
always-include: true              # Inject into every conversation
matcher:
  pattern: ".*\\b(bug|issue)\\b.*"
  flags: i
---
```

### [Commands](https://opencode.ai/docs/commands/)

**Create custom commands for repetitive tasks.**

Custom commands let you specify a prompt you want to run when that command is executed in the TUI.

```
/my-command
```

Custom commands are in addition to the built-in commands like `/init`, `/undo`, `/redo`, `/share`, `/help`.

Commands are skills executed via slash commands. They overlap but are stored differently:

- **Skills:** `~/.claude/skills` - broader workflow definitions
- **Commands:** `~/.claude/commands` - quick executable prompts

```bash
# Example skill structure
~/.claude/skills/
  pmx-guidelines.md      # Project-specific patterns
  coding-standards.md    # Language best practices
  tdd-workflow/          # Multi-file skill with README.md
  security-review/       # Checklist-based skill
```

**Key insight:** Composition is on-demand knowledge. The difference between Knowledge (dimension 1) and Composition is *when it loads*. Rules load every session. Skills load when invoked. Move anything that isn't needed every session from rules to skills.

---

## 5. Delegation

> *Can this be scoped and handed off?*
>
> **Directive:** Isolate context, return summaries.

### Subagents

Subagents are processes your orchestrator (main Claude) can delegate tasks to with limited scopes. They can run in background or foreground, freeing up context for the main agent.

Subagents work nicely with skills - a subagent capable of executing a subset of your skills can be delegated tasks and use those skills autonomously. They can also be sandboxed with specific tool permissions.

```bash
# Example subagent structure
~/.claude/agents/
  planner.md           # Feature implementation planning
  architect.md         # System design decisions
  tdd-guide.md         # Test-driven development
  code-reviewer.md     # Quality/security review
  security-reviewer.md # Vulnerability analysis
  build-error-resolver.md
  e2e-runner.md
  refactor-cleaner.md
```

Configure allowed tools, MCPs, and permissions per subagent for proper scoping.

### [Agents](https://opencode.ai/docs/agents/)

**Configure and use specialized agents.**

Agents are specialized AI assistants that can be configured for specific tasks and workflows. They allow you to create focused tools with custom prompts, models, and tool access.

### Foreground vs Background

- **Foreground** — Blocks main conversation, permission prompts pass through, MCP tools available
- **Background** — Concurrent execution, pre-approved permissions only, no MCP tools

Press `Ctrl+B` to background a running task.

### Subagent Configuration

```yaml
---
name: code-reviewer
description: Reviews code for quality
tools: Read, Grep, Glob
disallowedTools: Write, Edit
model: sonnet
permissionMode: dontAsk
memory: user
---
```

### Persistent Memory

Subagents can maintain memory across sessions:

- `memory: user` — `~/.claude/agent-memory/<name>/` (shared across projects)
- `memory: project` — `.claude/agent-memory/<name>/` (in version control)
- `memory: local` — `.claude/agent-memory-local/<name>/` (gitignored)

**Key insight:** Delegation is also a context isolation strategy. Subagents run in their own context window and return a summary. Verbose investigation work should be delegated — not because you're too busy, but because it protects your main session. (See dimension 7.)

---

## 6. Interaction

> *Is this a better way to talk to the agent?*
>
> **Directive:** Specify success criteria, not vibes.

This is the highest-leverage dimension. Configuration is table stakes. How you communicate is the multiplier.

### The Interview Pattern

Don't specify everything upfront. Let the agent interview you:

```
I want to build [brief description]. Interview me using AskUserQuestion.
Ask about technical implementation, UI/UX, edge cases, and tradeoffs.
Don't ask obvious questions — dig into the hard parts I might not have
considered. Keep going until we've covered everything, then write a
complete spec to SPEC.md.
```

This flips the dynamic: instead of anticipating everything, you leverage the agent's ability to ask structured questions.

### Verification-First Prompts

Don't say "implement X." Say:

```
Write a validateEmail function. Test cases: user@example.com → true,
invalid → false, user@.com → false. Run the tests after implementing.
```

Concrete success criteria produce dramatically better results than vibes.

### Plan Mode as a Workflow Stage

1. `Shift+Tab` to enter Plan Mode
2. Let Claude explore and propose
3. `Ctrl+G` to edit the plan in your editor
4. Switch to Normal Mode for execution

Separates exploration from implementation. Prevents the agent from charging ahead with edits before understanding the codebase.

### Rich Input

- **`@src/utils/auth.js`** — Includes file content directly in your prompt
- **Paste images** (`Ctrl+V`) — Screenshots for UI review, error messages, diagrams
- **Pipe data** — `cat error.log | claude` for instant context
- **`!command`** — Quick bash execution without agent interpretation

### Focused Compaction

Not just `/compact` — use the focus parameter:

```
/compact Focus on the API changes, discard the styling discussion
```

Surgical context preservation instead of blanket garbage collection.

### Separation of Concerns

Explicitly tell the agent what phase you're in:

- *"Explore this codebase. Don't change anything yet."*
- *"Now implement based on what we discussed."*
- *"Review what you just wrote. Look for edge cases."*

Phase separation prevents the most common failure mode: premature implementation.

---

## 7. Sustain

> *Does this help protect or extend my session?*
>
> **Directive:** Budget tokens like money.

**This is the meta-constraint. Every other dimension has a context cost. Sustain is the budget that governs them all.**

### The Context Budget

Your 200k tokens aren't all yours. Think of it as a budget:

- **Fixed costs** — Tool definitions, MCP schemas, rules, system prompt (loaded before you type anything)
- **Discretionary spend** — Your actual conversation and work

With too many tools enabled, your 200k might be 70k of usable space.

### Monitor: `/context`

The `/context` command shows a colored grid visualization of exactly what's consuming your context. This is the dashboard for the budget metaphor.

### Strategy 1: Disable Unused Capabilities

Be picky with MCPs. Keep all MCPs in user config but disable everything unused per project:

```markdown
# In ~/.claude.json under projects.[path].disabledMcpServers
disabledMcpServers: ["playwright", "cloudflare-docs", "clickhouse", "AbletonMCP"]
```

Navigate to `/plugins` and scroll down or run `/mcp`.

### Strategy 2: Delegate Verbose Work

Subagents run in their own context and return summaries. The investigation stays out of your main window:

```
Use the Explore agent to find all authentication-related files and
summarize the auth flow. Don't dump the file contents here.
```

This is the most powerful context management technique that almost nobody frames this way.

### Strategy 3: Skills Over Rules

Instructions in CLAUDE.md load every session (dimension 1). Instructions in skills load on demand (dimension 4). Move rarely-needed instructions from rules to skills for direct context savings.

### Strategy 4: Code Intelligence Plugins

TypeScript LSP gives Claude go-to-definition and type checking without reading entire files. Fewer file reads = less context consumed = longer, higher-quality sessions.

### Strategy 5: Focused Compaction

```
/compact Focus on the authentication changes, discard the CSS discussion
```

Override the auto-compaction threshold: `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` environment variable.

### Recovery

- **`Esc + Esc`** or **`/rewind`** — Rewind menu: restore code only, conversation only, or both
- **`/resume`** — Resume a previous session by ID or name
- **`/checkpoints`** — File-level undo points (tracks Claude's edits only, not Bash changes)

**Key insight:** Only Behavior (hooks) is truly free — zero context cost. Knowledge is always-on cost. Capabilities add tool definitions. Composition loads on invoke. Sustain is the budget that governs all other dimensions.

---

## 8. Environment

> *Does this improve my physical workspace?*
>
> **Directive:** Reduce friction between tools.

### Keyboard Shortcuts

- **Ctrl+U** - Delete entire line (faster than backspace spam)
- **!** - Quick bash command prefix
- **@** - Search for files
- **/** - Initiate slash commands
- **Shift+Enter** - Multi-line input
- **Tab** - Toggle thinking display
- **Esc Esc** - Interrupt Claude / restore code
- **Ctrl+B** - Background a running task
- **Ctrl+T** - Toggle task list
- **Ctrl+R** - Reverse search through history
- **Shift+Tab** / **Alt+M** - Cycle permission modes
- **Ctrl+V** - Paste image from clipboard
- **Alt+P** - Switch model without clearing prompt
- **Alt+T** - Toggle extended thinking

**macOS note:** Option/Alt shortcuts require terminal config — iTerm2: Settings → Profiles → Keys → Set Option to "Esc+". Terminal.app: Settings → Profiles → Keyboard → "Use Option as Meta Key".

### Parallel Workflows

**`/fork`** - Fork conversations to do non-overlapping tasks in parallel instead of spamming queued messages

**Git Worktrees** - For overlapping parallel Claudes without conflicts. Each worktree is an independent checkout

```bash
git worktree add ../feature-branch feature-branch
# Now run separate Claude instances in each worktree
```

### tmux for Long-Running Commands

Stream and watch logs/bash processes Claude runs.

**Letting claude code spin up the frontend and backend servers and monitoring the logs by attaching to the session using tmux**

```bash
tmux new -s dev
# Claude runs commands here, you can detach and reattach
tmux attach -t dev
```

### mgrep > grep

`mgrep` is a significant improvement from ripgrep/grep. Install via plugin marketplace, then use the `/mgrep` skill. Works with both local search and web search.

```bash
mgrep "function handleSubmit"  # Local search
mgrep --web "Next.js 15 app router changes"  # Web search
```

### Other Useful Commands

- **`/rewind`** - Go back to a previous state
- **`/statusline`** - Customize with branch, context %, todos
- **`/checkpoints`** - File-level undo points
- **`/compact`** - Manually trigger context compaction
- **`/context`** - Visualize what's consuming your context
- **`/stats`** - Daily usage, session history, streaks
- **`/vim`** - Toggle vim mode

### Editors

While an editor isn't needed it can positively or negatively impact your Claude Code workflow. While Claude Code works from any terminal, pairing it with a capable editor unlocks real-time file tracking, quick navigation, and integrated command execution.

#### Zed (My Preference)

I use Zed - a Rust-based editor that's lightweight, fast, and highly customizable.

**Why Zed works well with Claude Code:**

- **Agent Panel Integration** - Zed's Claude integration lets you track file changes in real-time as Claude edits. Jump between files Claude references without leaving the editor
- **Performance** - Written in Rust, opens instantly and handles large codebases without lag
- **CMD+Shift+R Command Palette** - Quick access to all your custom slash commands, debuggers, and tools in a searchable UI. Even if you just want to run a quick command without switching to terminal
- **Minimal Resource Usage** - Won't compete with Claude for system resources during heavy operations
- **Vim Mode** - Full vim keybindings if that's your thing

￼

**Zed Editor with custom commands dropdown using CMD+Shift+R.**

**Following mode shown as the bullseye in the bottom right.**

1. Split your screen - Terminal with Claude Code on one side, editor on the other
2. **Ctrl + G** - quickly open the file Claude is currently working on in Zed
3. **Auto-save** - Enable autosave so Claude's file reads are always current
4. **Git integration** - Use editor's git features to review Claude's changes before committing
5. **File watchers** - Most editors auto-reload changed files, verify this is enabled

#### VSCode / Cursor

This is also a viable choice and works well with Claude Code. You can use it in either terminal format, with automatic sync with your editor using `\ide` enabling LSP functionality (somewhat redundant with plugins now). Or you can opt for the extension which is more integrated with the Editor and has a matching UI.

￼

**From the docs directly at https://code.claude.com/docs/en/vs-code**

### GitHub Actions CI/CD

Set up code review on your PRs with GitHub Actions. Claude can review PRs automatically when configured.

￼

**Claude approving a bug fix PR**

### Sandboxing

Use sandbox mode for risky operations - Claude runs in restricted environment without affecting your actual system. (Use `--dangerously-skip-permissions` - to do the opposite of this and let claude roam free, this can be destructive if not careful.)

---

## My Setup

### Plugins

**Installed:** (I usually only have 4-5 of these enabled at a time)

```markdown
ralph-wiggum@claude-code-plugins       # Loop automation
frontend-design@claude-code-plugins    # UI/UX patterns
commit-commands@claude-code-plugins    # Git workflow
security-guidance@claude-code-plugins  # Security checks
pr-review-toolkit@claude-code-plugins  # PR automation
typescript-lsp@claude-plugins-official # TS intelligence
hookify@claude-plugins-official        # Hook creation
code-simplifier@claude-plugins-official
feature-dev@claude-code-plugins
explanatory-output-style@claude-code-plugins
code-review@claude-code-plugins
context7@claude-plugins-official       # Live documentation
pyright-lsp@claude-plugins-official    # Python types
mgrep@Mixedbread-Grep                  # Better search
```

### MCP Servers

**Configured (User Level):**

```json
{
  "github": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"] },
  "firecrawl": { "command": "npx", "args": ["-y", "firecrawl-mcp"] },
  "supabase": {
    "command": "npx",
    "args": ["-y", "@supabase/mcp-server-supabase@latest", "--project-ref=YOUR_REF"]
  },
  "memory": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-memory"] },
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  },
  "vercel": { "type": "http", "url": "https://mcp.vercel.com" },
  "railway": { "command": "npx", "args": ["-y", "@railway/mcp-server"] },
  "cloudflare-docs": { "type": "http", "url": "https://docs.mcp.cloudflare.com/mcp" },
  "cloudflare-workers-bindings": {
    "type": "http",
    "url": "https://bindings.mcp.cloudflare.com/mcp"
  },
  "cloudflare-workers-builds": { "type": "http", "url": "https://builds.mcp.cloudflare.com/mcp" },
  "cloudflare-observability": {
    "type": "http",
    "url": "https://observability.mcp.cloudflare.com/mcp"
  },
  "clickhouse": { "type": "http", "url": "https://mcp.clickhouse.cloud/mcp" },
  "AbletonMCP": { "command": "uvx", "args": ["ableton-mcp"] },
  "magic": { "command": "npx", "args": ["-y", "@magicuidesign/mcp@latest"] }
}
```

**Disabled per project (context window management):**

```markdown
# In ~/.claude.json under projects.[path].disabledMcpServers
disabledMcpServers: [
  "playwright",
  "cloudflare-workers-builds",
  "cloudflare-workers-bindings",
  "cloudflare-observability",
  "cloudflare-docs",
  "clickhouse",
  "AbletonMCP",
  "context7",
  "magic"
]
```

This is the key - I have 14 MCPs configured but only ~ 5-6 enabled per project. Keeps context window healthy.

### Key Hooks

```json
{
  "PreToolUse": [
    // tmux reminder for long-running commands
    { "matcher": "npm|pnpm|yarn|cargo|pytest", "hooks": ["tmux reminder"] },
    // Block unnecessary .md file creation
    { "matcher": "Write && .md file", "hooks": ["block unless README/CLAUDE"] },
    // Review before git push
    { "matcher": "git push", "hooks": ["open editor for review"] }
  ],
  "PostToolUse": [
    // Auto-format JS/TS with Prettier
    { "matcher": "Edit && .ts/.tsx/.js/.jsx", "hooks": ["prettier --write"] },
    // TypeScript check after edits
    { "matcher": "Edit && .ts/.tsx", "hooks": ["tsc --noEmit"] },
    // Warn about console.log
    { "matcher": "Edit", "hooks": ["grep console.log warning"] }
  ],
  "Stop": [
    // Audit for console.logs before session ends
    { "matcher": "*", "hooks": ["check modified files for console.log"] }
  ]
}
```

### Custom Status Line

Shows user, directory, git branch with dirty indicator, context remaining %, model, time, and todo count:

￼

**Example statusline in my Mac root directory**

### Rules Structure

```markdown
~/.claude/rules/
  security.md      # Mandatory security checks
  coding-style.md  # Immutability, file size limits
  testing.md       # TDD, 80% coverage
  git-workflow.md  # Conventional commits
  agents.md        # Subagent delegation rules
  patterns.md      # API response formats
  performance.md   # Model selection (Haiku vs Sonnet vs Opus)
  hooks.md         # Hook documentation
```

### Subagents

```markdown
~/.claude/agents/
  planner.md           # Break down features
  architect.md         # System design
  tdd-guide.md         # Write tests first
  code-reviewer.md     # Quality review
  security-reviewer.md # Vulnerability scan
  build-error-resolver.md
  e2e-runner.md        # Playwright tests
  refactor-cleaner.md  # Dead code removal
  doc-updater.md       # Keep docs synced
```

---

## Key Takeaways

1. **Knowledge costs context, Composition doesn't** — move rarely-used rules to skills
2. **Capability has a tax** — every enabled tool/MCP eats your context budget
3. **Behavior is free** — hooks run outside the context window; prefer hooks over rules for automation
4. **Interaction is the multiplier** — configuration is table stakes, communication craft is leverage
5. **Sustain governs everything** — context budget is the meta-constraint across all dimensions
6. **Delegate for isolation** — subagents protect your main context, not just your time
7. **Scope gravity** — push everything to the lowest level that still works

---

## References

- [Plugins Reference](https://opencode.ai/docs/plugins/)
- [Hooks Documentation](https://opencode.ai/docs/hooks/)
- [Checkpointing](https://opencode.ai/docs/checkpoints/)
- [Interactive Mode](https://opencode.ai/docs/interactive-mode/)
- [Memory System](https://opencode.ai/docs/memory/)
- [Subagents](https://opencode.ai/docs/agents/)
- [MCP Overview](https://opencode.ai/docs/mcp-servers/)

---

**Note:** This is a subset of detail. I might make more posts on specifics if people are interested.
