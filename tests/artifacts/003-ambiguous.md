# Using subagents as "disposable research assistants"

**Source:** Discord conversation in OpenCode community
**Captured:** 2026-02-06
**Raw notes:** This is either a delegation pattern or a context management strategy. Or both? The framing of "disposable" is interesting — use and discard, protecting main context.

---

Someone shared their pattern: before starting any complex task, they spin up an Explore subagent to do all the codebase investigation. The subagent reads dozens of files, traces dependencies, maps the architecture — burning through context doing it. Then it returns a 10-line summary to the main conversation.

The main conversation gets the insight without the context cost.

They called these "disposable research assistants" — you use them for one investigation and they're gone. The knowledge transfers via the summary, but the verbose exploration stays isolated.

"Think of subagents as scratch paper. You do your messy work there, then copy the clean answer to the final sheet."
