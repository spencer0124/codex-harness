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
4. Start Codex and run the phases in order. Do not update Codex during the task. `doctor.sh` only reports the version.

	| Phase | Type | You do |
	|---|---|---|
	| Analysis | `$analyze` | Give the end time. Send the question block to the stakeholder and paste the answers back with `$analyze integrate`. Repeat until no P0 or P1 question is open. |
	| Plan | `$plan` | Approve the requirement and unit lists. This is the only planned checkpoint. |
	| Build | `$build` | Nothing. Open the preview when the first screen lands. Report what looks wrong with `$ui fix <request>`. |
	| Write-up | `$writeup` | Read the docs after the feature freeze. |
	| Practice | `$drill` | Answer the questions yourself, timed. |

	While it runs:

	- **Server.** Codex never starts the dev server. During the routes unit it asks you once: open a second terminal, run `npm run dev`, leave it running, and open that port in the IDE preview. `tsx watch` reloads it on every change.
	- **Approvals.** The first time Codex asks to run the test suite, `git commit`, `curl` to localhost, or `playwright-cli`, choose the option that stops asking for that command. Otherwise the loop stops at every unit. Refuse wide deletes and global installs.
	- **Verdicts.** Each unit report lists the review findings with 수용, 수정, or 폐기. Read them; they are what `AI_COLLABORATION.md` will say you did. To overrule one, reply `F3 수용해` with a reason. The loop does not wait for you.
	- **Spot-check.** `$writeup` gives you three pairs of commands that print an input row and the result for it. Run them and reply `일치` or what differs.
	- **Restart.** If Codex exits, start it again and type the current phase (usually `$build`). The state is in PLAN.md. If `$build` does not load as a skill, Codex reads `.agents/skills/build/SKILL.md` instead.

5. Before you submit, move the practice material out and check that nothing of it is tracked.

	```bash
	bash scripts/presubmit.sh --fix
	bash scripts/presubmit.sh
	```

	The second run must print `presubmit: clean`. It fails when practice files are tracked, when the practice marker appears in a tracked file or in git history, or when a practice folder is still in the workspace. Save every open editor tab in the IDE before you submit.

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
