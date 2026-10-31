# codex-harness

A small, generic process harness for a coding agent working in a fresh repository: working rules, playbooks, and document templates. It holds no application code.

## Apply

```bash
git clone https://github.com/spencer0124/codex-harness ~/harness
bash ~/harness/apply.sh "$PWD"
```

`apply.sh` copies files only and uses no network. An existing `AGENTS.md` gets the rules appended; existing templates are left alone.

## Contents

| Path | Copied to | Purpose |
| --- | --- | --- |
| `AGENTS.md` | `AGENTS.md` | Working rules the agent loads every session |
| `playbooks/` | `docs/playbooks/` | Read on demand: verification, selective TDD, decision log, write-up |
| `templates/` | `PLAN.md`, `DECISIONS.md`, `REPORT.md` | Document skeletons |
| `scripts/smoke.sh` | `scripts/smoke.sh` | One curl check per requirement against a local server |

## Sources

Section 3 of `AGENTS.md` is a condensed excerpt of [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT). See `THIRD_PARTY.md`.
