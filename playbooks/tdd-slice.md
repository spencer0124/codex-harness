# Selective TDD

Test first for: business logic, rules with boundaries, edge cases a C# or A# names, and every accepted review finding (F#).
Not test first: wiring, styling, config. Check those with a smoke line or a screenshot.

One slice, one turn:
1. Write the test named `R#: <behavior>`.
2. Run it. Show the failing output and confirm it fails for the expected reason.
3. Implement the minimum to pass. Do not touch the test.
4. Run the whole suite. Show the summary line.

For an F#, the red output from step 2 becomes an E# with `판정: FAIL` and the line `메모: 의도한 red (F# 재현)`. That entry and the green E# after it show the order: reproduce, test, fix.

If a test looks wrong: stop and explain. Change neither code nor test until told.

Before each commit, check that no older test changed:
`git diff --stat HEAD -- tests '*.test.ts'`
