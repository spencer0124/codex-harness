# Decision log

Write a D# entry in DECISIONS.md only when a real choice was made. D1 holds the core decision, the one the product depends on.

- Choice: what was picked.
- How it works: input → processing → output in three to five lines, with `file:function`.
- Rejected: alternatives actually considered, and how each differs from the choice. If one was not measured, write "검토만, 실측 안 함". Never invent alternatives.
- Given up: what this choice costs, named concretely.
- Reason: one or two lines.
- Evidence: test name, E#, C# (stakeholder answer), or measurement.
- Known weakness and failure behavior: what breaks, when, and how it fails.

Log every AI proposal and review finding in `docs/AI_LOG.md` as an F# row when it happens, including findings that changed nothing. DECISIONS.md "AI 제안 → 내 변경" copies only the F#s that changed a decision. Zero is a valid count.
