# Calibration Test Results — 2026-02-06

First test run using 3 synthetic artifacts to validate the Roux classification system.

---

## Artifact 001: Auto-format on save using PostToolUse hooks

### Pass A (Unstructured)
- **Decision:** This is a useful hook pattern. I'd probably add it to my hooks config or note it somewhere.
- Clarity: 3/5 — I know it's useful but "add it somewhere" is vague
- Actionability: 3/5 — I could act, but where exactly? Which file? Replace what?
- Precision: 2/5 — "Note it somewhere" is imprecise
- Durability: 3/5 — I'd probably forget where I noted it
- Efficiency: 4/5 — Quick to read and understand
- **Total: 15/25**

### Pass B (Roux-classified)
- **Triple:** `(Behavior, Project, System)`
- **Gravity check:** Project scope is correct — formatting rules vary per project
- **Agency check:** System — this is a hook, not a human behavior or agent instruction
- **Tension:** Behavior ←→ Knowledge tension confirmed. This is currently a CLAUDE.md instruction in some setups ("always format code"). Roux says: if it can be a hook, it shouldn't be a rule. Move it.
- **Route:** Fold into existing. Check current hooks config, add or refine the PostToolUse formatter.
- **Identity lens:** Yes — reduces friction, improves DX, zero overhead. Binchotan.
- **Fond:** "Formatting enforcement belongs in hooks (zero context cost), not rules (always-on cost)."
- Clarity: 5/5 — Exact destination, exact action
- Actionability: 5/5 — Can act immediately: edit hooks config
- Precision: 5/5 — Lands in exactly the right place
- Durability: 5/5 — Hook pattern is provider-agnostic, the concept transfers
- Efficiency: 4/5 — Classification took a moment but produced clear result
- **Total: 24/25**

### Delta: +9
- **Where Roux helped:** The Behavior ←→ Knowledge tension detection was the key insight. Without it, this is "a useful tip." With it, it's "a specific action to take: move formatting from rules to hooks." The triple gave it an exact address.
- **Where Roux didn't help:** Minimal overhead for a clearly technical item. The unstructured pass already knew it was useful.
- **Refinement needed:** None. Clean classification. This is Roux's sweet spot.

---

## Artifact 002: The 100ms rule: perceived vs actual performance

### Pass A (Unstructured)
- **Decision:** Great insight. Applies to CLI tools and UX in general. Keep as reference? Maybe add to design notes?
- Clarity: 2/5 — "Keep as reference" and "maybe add to design notes" are both vague
- Actionability: 2/5 — No clear next step
- Precision: 1/5 — No destination at all
- Durability: 2/5 — Without a home, this insight will be lost
- Efficiency: 5/5 — Instant to understand
- **Total: 12/25**

### Pass B (Roux-classified)
- **Triple:** Does not produce a clean agentic triple.
- **Dimension:** Not Knowledge (not an agent instruction). Not Behavior (not a hook). Not Capability, Composition, Delegation, Sustain, or Environment. This is a *craft principle* — it's about how humans should design interfaces.
- **Agency:** Human. This changes how *you* design, not how the agent behaves.
- **Route:** Conventions stream. This is an identity-lens item — it codifies what "joyously delightful UX" means in practice. It belongs in the craft principles / conventions document (when that exists).
- **Identity lens:** Strong yes. "The best interfaces don't eliminate waiting. They eliminate the feeling of waiting." This IS the identity.
- **Fond:** "Perceived performance > actual performance. Design for the feeling, not the metric."
- Clarity: 4/5 — Clear that it's conventions, not agentic. Clear destination.
- Actionability: 3/5 — Conventions doc doesn't exist yet, but we know it should go there
- Precision: 4/5 — Correctly identified as non-agentic; routed to the right stream
- Durability: 5/5 — This principle is timeless
- Efficiency: 3/5 — Required the "no clean triple" recognition step
- **Total: 19/25**

### Delta: +7
- **Where Roux helped:** The critical insight was recognizing this *doesn't* produce a clean agentic triple — and that's informative, not a failure. Without Roux, this drifts as "a nice insight." With Roux, it's correctly classified as conventions material, preserving its value without polluting the agentic system.
- **Where Roux didn't help:** The conventions stream doesn't have a formal home yet, so actionability is limited.
- **Refinement needed:** The conventions document needs to exist for this routing to be fully actionable. Added to shopping cart.

---

## Artifact 003: Using subagents as "disposable research assistants"

### Pass A (Unstructured)
- **Decision:** Good pattern. Relates to context management and delegation. Maybe update my subagent docs? Or add as a tip?
- Clarity: 2/5 — "Maybe update docs? Or add as a tip?" — unclear
- Actionability: 2/5 — Multiple possible actions, none chosen
- Precision: 2/5 — Could go to delegation docs, context docs, tips section...
- Durability: 3/5 — The pattern is clear even if the destination isn't
- Efficiency: 4/5 — Quick to understand
- **Total: 13/25**

### Pass B (Roux-classified)
- **Triple:** `(Delegation, Session, Agent)` — primary. But tension detected.
- **Tension:** Delegation ←→ Sustain. This is both a delegation pattern AND a context management strategy. The triple captures the primary dimension (Delegation — it's about handing work off to subagents). But the *reason* for the pattern is Sustain (protecting context budget).
- **Gravity check:** Session scope — this is a technique you invoke when needed, not an always-on rule.
- **Agency check:** Agent — the agent needs to know this pattern exists so it can be instructed to use it.
- **Route:** Fold into existing. This insight already lives in FRAMEWORK.md under both Dimension 5 (Delegation: "Verbose investigation work should be delegated — not because you're too busy, but because it protects your main session") and Dimension 7 (Sustain: Strategy 2 — "Delegate Verbose Work"). The framework already captured this pattern. No action needed — Roux confirms the framework is complete here.
- **Identity lens:** Yes — elegant, minimal, effective. Good DX.
- **Fond:** "Subagents are context firewalls, not just task runners."
- Clarity: 5/5 — Clear classification, clear tension, clear routing
- Actionability: 5/5 — Action is: nothing. Framework already covers this. Confirmed.
- Precision: 5/5 — Identified exact location where this already lives
- Durability: 5/5 — The pattern is provider-agnostic
- Efficiency: 3/5 — Tension detection required checking two dimensions
- **Total: 23/25**

### Delta: +10
- **Where Roux helped:** The tension detection was the key. Without Roux, you'd agonize over whether this is a delegation pattern or a context strategy. Roux says: it's primarily Delegation, but the motivation is Sustain, and the framework already captures both angles. Result: do nothing, you're already covered. That "do nothing" confidence is extremely valuable.
- **Where Roux didn't help:** N/A — this was a clean win.
- **Refinement needed:** None. The tension detection and "already covered" routing both worked perfectly.

---

## Batch Analysis

**Artifacts tested:** 3

### Score Summary

| Criterion | Avg Unstructured | Avg Roux | Delta |
|-----------|-----------------|----------|-------|
| Clarity | 2.3 | 4.7 | **+2.4** |
| Actionability | 2.3 | 4.3 | **+2.0** |
| Precision | 1.7 | 4.7 | **+3.0** |
| Durability | 2.7 | 5.0 | **+2.3** |
| Efficiency | 4.3 | 3.3 | **-1.0** |
| **Total** | **13.3** | **22.0** | **+8.7** |

### Classification Distribution

| Dimension | Count | % |
|-----------|-------|---|
| Behavior | 1 | 33% |
| Delegation | 1 | 33% |
| No clean triple (Conventions) | 1 | 33% |

### Routing Distribution

| Route | Count | % |
|-------|-------|---|
| Fold into existing | 1 | 33% |
| Conventions stream | 1 | 33% |
| Already covered (no action) | 1 | 33% |

### Key Findings

1. **Precision is the biggest win (+3.0).** Roux's greatest value is giving items exact addresses instead of vague "put it somewhere" decisions.

2. **Efficiency is the one cost (-1.0).** Classification takes slightly more cognitive effort than freeform processing. This is expected and acceptable — the payoff in every other dimension justifies the investment.

3. **Tension detection is unexpectedly valuable.** Artifact 003 showed that recognizing cross-dimension tension (Delegation ←→ Sustain) produces the most confident routing. The tension itself is informative.

4. **"No clean triple" is a feature, not a failure.** Artifact 002 couldn't produce an agentic triple, and that was the correct classification — it's conventions material, not agentic tooling. The system correctly identified its own boundary.

5. **"Already covered" is a valid and valuable outcome.** Not every item needs action. Roux confirmed that the framework already captured the insight from Artifact 003. That confidence prevents unnecessary duplication.

### Framework Refinements

- **None needed for classification system.** All three test types (clean agentic, non-agentic conventions, ambiguous/tensioned) were handled correctly.
- **Conventions document needed.** The conventions stream has nowhere to route to yet. This is the most pressing gap. (Added to shopping cart.)
- **Scoring rubric validated.** The 5-criterion model captured meaningful differences. The efficiency cost is real but acceptable.

---

*Calibration complete. Roux is ready for real inbox items.*
