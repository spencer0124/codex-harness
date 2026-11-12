<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/en/d/db/Yoshi_%28Nintendo_character%29.png" alt="Yoshi" width="160">
</p>

# yoshi-hackathon

A process harness for Codex in a fresh task repository. The main session orchestrates. Custom agents analyze the task, build each unit test-first, review it, and verify it. Every step leaves evidence that the final docs cite. The harness holds no application code.

## What it does at a hackathon

- **Pins down the task.** Turns the brief into conditions and open questions, and runs the Q&A rounds with the stakeholder until nothing important is open.
- **Picks an approach.** Compares candidate designs from three angles, runs short spikes, and shows the pick on one screen for you to approve.
- **Builds while you watch.** Writes each unit test-first, reviews it, and verifies it in the browser, so you only open the preview and report what looks wrong.
- **Writes the submission.** Produces the report, the decision log, and the AI collaboration log from the evidence, boots the committed code in a clean copy, and runs a security review last.
- **Prepares the pitch.** Drills you with timed questions and a three-minute pitch script.
- **Keeps it clean.** Checks before you submit that no practice material is tracked or left in git history.

## Use it on a task

1. Apply the harness to the workspace. It copies files only, needs no network, and keeps any file that already exists.

	```bash
	git clone https://github.com/spencer0124/yoshi-hackathon ~/harness
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
	| Approach | `$approach` | Codex fixes the criteria, compares candidates from three lenses, runs short spikes, and reports its pick on one screen. Approve it with a one-line reason; `$plan` then starts on its own. Run it in Default mode, not Plan mode. |
	| Plan | `$plan` | Answer any questions its builder check raises, then approve the requirement and unit lists. |
	| Build | `$build` | Nothing. Open the preview when the first screen lands. Report what looks wrong with `$ui fix <request>`. |
	| Write-up | `$writeup` | Read the docs after the feature freeze. Its verification step boots the committed code in a temp copy on port 3100, then runs the security review last; critical findings go back to `$build`. |
	| Practice | `$drill` | Answer the questions yourself, timed. Read the three-minute pitch script in `.study/pitch.md` aloud once and reply with the seconds. |

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
| `.agents/skills/` | `analyze`, `approach`, `plan`, `build`, `ui`, `writeup`, `drill`, plus the vendored `frontend-design`, `humanize-korean`, and `security-best-practices` |
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

Section 9 of `AGENTS.md` is a condensed excerpt of [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT). The `approach` skill and the builder check in the `plan` skill adapt the `brainstorming` skill of [obra/superpowers](https://github.com/obra/superpowers) (MIT). The `approach` skill also follows the independent drafts and blind comparison of pstack `arena` and [karpathy/llm-council](https://github.com/karpathy/llm-council), and the [MADR](https://adr.github.io/madr/) decision layout; no text from those was copied. Vendored skills and their licenses are listed in `THIRD_PARTY.md`.
