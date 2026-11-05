# codex-harness

A process harness for Codex in a fresh task repository. The main session orchestrates. Custom agents analyze the task, build each unit test-first, review it, and verify it. Every step leaves evidence that the final docs cite. The harness holds no application code.

## Use it on a task

1. Apply the harness to the workspace. It copies files only, needs no network, and keeps any file that already exists.

	```bash
	git clone https://github.com/spencer0124/codex-harness ~/harness
	bash ~/harness/apply.sh "$PWD"
	```

2. Install the browser tools, then check the machine. Fix every `FAIL` line before you start.

	```bash
	bash scripts/install-tools.sh
	bash scripts/doctor.sh
	```

3. Commit the harness: `git add -A && git commit -m "chore: apply codex-harness"`.
4. Start Codex and run the phases in order.

	| Phase | Type | You do |
	|---|---|---|
	| Analysis | `$analyze` | Give the end time. Send the question block to the stakeholder and paste the answers back with `$analyze integrate`. Repeat until no P0 or P1 question is open. |
	| Plan | `$plan` | Approve the requirement and unit lists. This is the only planned checkpoint. |
	| Build | `$build` | Nothing. Open the preview when the first screen lands. Report what looks wrong with `$ui fix <request>`. |
	| Write-up | `$writeup` | Read the docs after the feature freeze. |
	| Practice | `$drill` | Answer the questions yourself, timed. |

5. Before you submit, move the practice material out and check that nothing of it is tracked.

	```bash
	bash scripts/presubmit.sh --fix
	bash scripts/presubmit.sh
	```

	The second run must print `presubmit: clean`. It fails when practice files are tracked, when the practice marker appears in a tracked file or in git history, or when a practice folder is still in the workspace.

## What lands in the workspace

| Path | Purpose |
|---|---|
| `AGENTS.md` | Rules Codex loads every session: phases, the orchestrator role, ids, tests, docs |
| `.agents/skills/` | `analyze`, `plan`, `build`, `ui`, `writeup`, `drill`, plus the vendored `frontend-design` and `humanize-korean` |
| `.codex/agents/` | `analyst`, `planner`, `implementer`, `reviewer`, `verifier`, `ui-tester` |
| `PLAN.md`, `DECISIONS.md`, `REPORT.md`, `AI_COLLABORATION.md` | Document skeletons, in Korean |
| `docs/` | `analysis/` (conditions, questions, data profile), `ARCHITECTURE.md`, `EVIDENCE.md`, `AI_LOG.md`, `RISKS.md`, `playbooks/` |
| `design/DESIGN.md` | Design tokens and components for the frontend |
| `scripts/` | `doctor.sh`, `install-tools.sh`, `fetch-logo.sh`, `smoke.sh`, `what-if.mjs`, `check-refs.sh`, `presubmit.sh` |
| `.gitignore` block | Keeps `.study/`, the drill skill, `_workspace/`, `.harness/`, `var/`, and tool caches out of git |

`$drill` writes only under `.study/`, and every file there starts with the practice marker. `scripts/presubmit.sh` keys on that marker and on the gitignore block.

## Test the harness

`bash tests/run.sh` checks `apply.sh` and `scripts/presubmit.sh` in throwaway repositories, then runs every `tests/*.test.sh`. It ends with `all suites: OK`. The data profiler has its own test: `node --test .agents/skills/analyze/scripts/profile-data.selftest.mjs`.

## Sources

Section 9 of `AGENTS.md` is a condensed excerpt of [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT). Vendored skills and their licenses are listed in `THIRD_PARTY.md`.
