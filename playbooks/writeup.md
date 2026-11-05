# Write-up checklist

The `writeup` skill runs this list. If the task names its own files, map these items onto them.

- [ ] Every R# has a traceability row: C# or A#, `file:function`, test or smoke line, E#, status (VERIFIED / HUMAN-CHECKED / ASSUMED / NOT-IMPLEMENTED), how to check it, commit.
- [ ] D1 holds the core decision with every field: how it works, each rejected alternative and how it differs, what was given up, evidence, weakness.
- [ ] `docs/ARCHITECTURE.md` matches the code: every module in the table exists, and each piece of state has exactly one owner.
- [ ] `docs/RISKS.md` covers condition change, mid-way failure, concurrent requests, boundary dates, hidden conditions, and abnormal input, each with current behavior and its test or 미검증.
- [ ] REPORT.md 지표와 민감도 has metric definitions with `file:function`, the what-if table copied from an E#, and the limits of each metric.
- [ ] Each AI_COLLABORATION.md case has the full chain: found, reproduced, failing test, fix, passing suite, and a verdict with evidence for every AI output involved.
- [ ] Every number is copied from an E#. Every cited E#, test name, and `file:function` resolves.
- [ ] `.harness/claim-audit.md` has no claim left without evidence or a label.
- [ ] Nothing is addressed to graders or reviewers. Nothing comes from `.study/`.
- [ ] Handoff: current state, next step, and open questions in five lines.
