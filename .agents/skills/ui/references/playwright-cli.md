# playwright-cli commands used by the ui skill

Checked against `@playwright/cli` 0.1.22 (`playwright-cli --help <command>`). Run every command through the wrapper, which picks the pinned binary and keeps browser state inside the workspace:

```bash
p() { bash .agents/skills/ui/scripts/pw.sh -s=ui "$@"; }
```

`-s=<name>` selects a named browser session. The session stays open between commands until `close`. A new session starts at a 1280x720 viewport. Add `--raw` before the command to print only the result value. For anything not listed here, run `p --help <command>`.

## Session
| Command | Does |
|---|---|
| `p open [url]` | Starts the headless browser for the session and opens the URL. `--headed` shows a window (not useful in a web IDE). |
| `p goto <url>` | Navigates and waits for the load event. |
| `p reload` | Reloads the page. |
| `p resize <w> <h>` | Sets the viewport size. |
| `p close` | Closes the session's browser. |
| `p list` | Lists open sessions. `p close-all` closes them, `p kill-all` kills stuck ones. |

## Look
| Command | Does |
|---|---|
| `p screenshot --filename <path.png>` | Saves the viewport. `--full-page` saves the whole scroll height. `p screenshot <ref-or-selector> --filename ...` saves one element. |
| `p snapshot` | Prints the accessibility tree with element refs (`e12`). `--boxes` adds each element's box. `--filename <x.md>` saves it instead. |
| `p --raw eval "() => document.title"` | Runs a function in the page and prints the result. `p eval "(el) => el.scrollWidth" <selector>` runs it on one element. |
| `p --raw run-code --filename <file.js>` | Runs a file that holds one `async page => { ... }` function expression. No `require` or `import`. `scripts/layout-checks.js` uses this. |
| `p --raw console error` | Prints console messages at error level and above, with a `Total messages: N (Errors: N, Warnings: N)` line. `--clear` empties the list. |
| `p requests --filter "/api/"` | Lists network requests since the page loaded. `p request <n>` shows one. |

## Act
| Command | Does |
|---|---|
| `p click <ref-or-selector>` | Clicks. Take a fresh `snapshot` first when using refs. |
| `p fill <ref-or-selector> <text>` | Fills an input. |
| `p select <ref-or-selector> <value>` | Picks an option. |
| `p press <key>` | Presses a key, for example `Enter` or `Tab`. |
| `p set-reduced-motion reduce` | Turns off animations before screenshots if they make shots flaky. |

## Mock the API
| Command | Does |
|---|---|
| `p route "**/api/plans" --status 500 --body '{"error":"x"}'` | Answers matching requests with a fixed response. `--content-type application/json` sets the type. |
| `p unroute` | Removes all routes (`p unroute "<pattern>"` removes one). |

A delayed response for the loading state needs `run-code`, because `route` has no delay option:

```bash
p run-code "async page => { await page.route('**/api/plans', async r => { await new Promise(x => setTimeout(x, 5000)); await r.continue(); }); }"
p goto http://127.0.0.1:3000/
p screenshot --filename .harness/screenshots/U4-loading-1440x900.png
```

## Files it writes
- `.playwright-cli/`: default output folder for unnamed screenshots and snapshots. `playwright-cli install` adds it to `.gitignore`.
- `.playwright/cli.config.json`: written by `install` when it falls back to Chromium.
- `.harness/tools/ms-playwright/`: the downloaded browser. `.harness/cache/`: the session daemon on Linux.
