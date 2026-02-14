# The 100ms rule: perceived vs actual performance

**Source:** Blog post on web performance
**Captured:** 2026-02-06
**Raw notes:** This resonated. Not about making things fast — about making things FEEL fast. Applies to CLI tools too.

---

Users perceive actions under 100ms as instantaneous. Between 100ms-1s, they notice delay but stay in flow. Over 1s, they mentally context-switch.

The implication: you don't always need to make things faster. You need to make the *feedback* faster. Show a spinner at 100ms. Show progress at 1s. Show partial results as they arrive.

This is why streaming responses feel so much better than waiting for a complete response — even when total time is the same.

"The best interfaces don't eliminate waiting. They eliminate the feeling of waiting."
