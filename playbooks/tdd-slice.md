# Selective TDD

Test first for: business logic, rules with boundaries, edge cases the stakeholder named.
Not test first: wiring, styling, config. Check those with a smoke line or the preview.

One slice, one turn:
1. Write the test named `R#: <behavior>`.
2. Run it. Show the failing output and confirm it fails for the expected reason.
3. Implement the minimum to pass. Do not touch the test.
4. Run the whole suite. Show the summary line.

If a test looks wrong: STOP and explain. Change neither code nor test until told.

Before each commit, check that no test was changed by accident:
`git diff --stat -- '*test*' '*spec*'`
