# Roux Testing Framework

## Purpose

Validate that the Roux classification system produces consistent, accurate, and actionable results when processing real-world agentic information. Measure the delta between unstructured processing and Roux-classified processing.

---

## Test Structure

### 1. Test Artifacts

Test artifacts live in `tests/artifacts/`. Each is a markdown file representing a real-world capture — the kind of thing that lands in a Sigil inbox.

**Artifact format:**

```markdown
# [Title]

**Source:** [URL, tweet, blog, conversation, etc.]
**Captured:** [Date]
**Raw notes:** [Any context from the capture moment]

---

[The actual content — pasted text, screenshot description, notes, etc.]
```

### 2. Test Protocol

For each artifact, two passes are performed:

**Pass A — Unstructured (control)**
Process the artifact the way you would without Roux. Freeform. What would you do with this? Where would it go? What's the takeaway?

**Pass B — Roux-classified (test)**
Apply the full classification:

```
1. CLASSIFY: (Dimension, Scope, Agency)
2. GRAVITY CHECK: Is this at the lowest scope that still works?
3. AGENCY CHECK: Is this routed to the correct consumer?
4. TENSION CHECK: Does this span two dimensions? Note the tension.
5. ROUTE: Fold into existing? New primitive? Conventions? Discard?
6. IDENTITY LENS: Does this serve beautiful, durable systems tooling?
7. FOND: What's the kernel? One sentence.
```

### 3. Scoring

Each pass is scored on 5 criteria (1-5 scale):

| Criterion | What It Measures |
|-----------|-----------------|
| **Clarity** | How clear is the decision about what to do with this item? |
| **Actionability** | Can you act on the result immediately, or does it need more thought? |
| **Precision** | Does the result land in exactly the right place, or is it approximate? |
| **Durability** | Will this classification still make sense in 6 months? |
| **Efficiency** | How much cognitive effort did the classification require? |

**Score interpretation:**

```
5 = Exceptional — crystal clear, immediately actionable, exactly right
4 = Strong — clear direction, minor refinement needed
3 = Adequate — reasonable but could be sharper
2 = Weak — vague, requires significant additional thought
1 = Failed — classification didn't help or actively confused
```

### 4. Comparative Analysis

After scoring both passes, produce:

```markdown
## Artifact: [Title]

### Pass A (Unstructured)
- Decision: [What you'd do with it]
- Clarity: X/5
- Actionability: X/5
- Precision: X/5
- Durability: X/5
- Efficiency: X/5
- **Total: XX/25**

### Pass B (Roux-classified)
- Triple: (Dimension, Scope, Agency)
- Route: [Fold/New/Conventions/Discard]
- Fond: [One-sentence kernel]
- Clarity: X/5
- Actionability: X/5
- Precision: X/5
- Durability: X/5
- Efficiency: X/5
- **Total: XX/25**

### Delta
- Score difference: +/- X
- Where Roux helped: [Specific improvement]
- Where Roux didn't help: [Any friction or overhead]
- Refinement needed: [What to adjust in the framework]
```

### 5. Batch Analysis

After running N artifacts, produce aggregate results:

```markdown
## Batch Results: [Date]

Artifacts tested: N

### Score Summary
| Criterion | Avg Unstructured | Avg Roux | Delta |
|-----------|-----------------|----------|-------|
| Clarity | X.X | X.X | +X.X |
| Actionability | X.X | X.X | +X.X |
| Precision | X.X | X.X | +X.X |
| Durability | X.X | X.X | +X.X |
| Efficiency | X.X | X.X | +X.X |
| **Total** | **X.X** | **X.X** | **+X.X** |

### Classification Distribution
| Dimension | Count | % |
|-----------|-------|---|
| Knowledge | X | X% |
| Capability | X | X% |
| ... | ... | ... |

### Routing Distribution
| Route | Count | % |
|-------|-------|---|
| Fold into existing | X | X% |
| New primitive | X | X% |
| Conventions | X | X% |
| Discard | X | X% |

### Key Findings
- [What worked well]
- [What needs refinement]
- [Surprises or patterns]

### Framework Refinements
- [Specific changes to make based on test results]
```

---

## Running a Test

### Quick Test (1 artifact)

```
Process this artifact through Roux. Run both Pass A (unstructured) and
Pass B (classified). Score both passes. Show the comparative analysis.
```

### Batch Test (full inbox)

```
Run the Roux test protocol on all artifacts in tests/artifacts/.
Produce individual comparisons and the batch analysis.
```

### Creating Test Artifacts from Sigil Inbox

```
Take the next N items from my Sigil inbox and create test artifacts
in roux/tests/artifacts/. Don't process them yet — just format them
as test artifacts.
```

---

## Sample Test Artifacts

Three synthetic artifacts are provided in `tests/artifacts/` for initial calibration:

- `001-hook-pattern.md` — A technical tip about hooks (should classify cleanly)
- `002-design-principle.md` — A UX insight (should route to conventions, not agentic)
- `003-ambiguous.md` — Something that could go multiple ways (tests tension detection)

These are for calibrating the scoring rubric before running against real inbox items.
