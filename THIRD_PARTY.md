# Third-party material

## DietrichGebert/ponytail

- Used: condensed excerpt of `AGENTS.md` (section 9 of this repository's `AGENTS.md`)
- Source: https://github.com/DietrichGebert/ponytail/blob/2a1fe842d078cf66ec7f3e6096a8ca4279c2cad7/AGENTS.md
- License: MIT. Copyright (c) 2026 DietrichGebert. Full text below.

```text
MIT License

Copyright (c) 2026 DietrichGebert

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## anthropics/skills: frontend-design

- Used: `.agents/skills/frontend-design/SKILL.md` and `LICENSE.txt`, copied unchanged
- Source: https://github.com/anthropics/skills/tree/41bbe19d1a1a7eaab5e7bb9050a417e5c6cffc8f/skills/frontend-design
- License: Apache License 2.0. Full text in `.agents/skills/frontend-design/LICENSE.txt`.

## epoko77-ai/im-not-ai: humanize-korean (v2.3.2)

- Used: `.agents/skills/humanize-korean/`, the Codex skill (`codex/skills/humanize-korean/`) with its `references/` symlink resolved to `skills/humanize-korean/references/` and the runtime scripts copied from `scripts/` (the same layout `install.sh --copy` produces). No file was edited.
- Source: https://github.com/epoko77-ai/im-not-ai/tree/b37e0206d31fffd9149bf57168d4d62eb2086bee
- License: MIT. Copyright (c) 2026 epoko77-ai. Full text in `.agents/skills/humanize-korean/LICENSE`.

## microsoft/playwright-cli (`@playwright/cli` 0.1.22)

- Used: not vendored. `scripts/install-tools.sh` installs the pinned npm package into `.harness/tools/` at contest time. `.agents/skills/ui/references/playwright-cli.md` is our own summary of its `--help` output.
- Source: https://www.npmjs.com/package/@playwright/cli
- License: Apache License 2.0.

## VoltAgent/awesome-design-md

- Used: the section layout and token format of `design-md/apple/DESIGN.md` (Google Stitch DESIGN.md format) as the template for `design/DESIGN.md`. No text was copied. The values in `design/DESIGN.md` were measured from the reference site it names.
- Source: https://github.com/VoltAgent/awesome-design-md
- License: MIT.
