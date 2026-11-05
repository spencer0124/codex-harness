# Layout checks and states

`scripts/shoot.sh` runs `scripts/layout-checks.js` once per viewport and prints one JSON object:

```json
{"viewport":[390,844],"ok":false,"issues":{"pageOverflowX":1026,"offscreen":[],"clipped":[],"overflowParent":[],"smallViews":[],"overlaps":[]},"tinyText":0,"unnamedButtons":1}
```

`ok` is true only when every list under `issues` is empty and `pageOverflowX` is at most 1. Each entry names the element with a short CSS path (`div.route-panel > svg`).

## What each issue means and the usual cause
| Issue | Means | Usual cause | Fix at the cause |
|---|---|---|---|
| `pageOverflowX` | The page scrolls sideways by N px | A fixed width wider than the viewport, a table without a scroller, a long unbroken string | `max-width: 100%`, wrap the table in a box with `overflow-x: auto`, `overflow-wrap: anywhere` on IDs and paths |
| `offscreen` | An element sticks out past the left or right edge, outside any horizontal scroller | Same as above, or negative margins | Same as above |
| `clipped` | Text is cut by `overflow: hidden` with no ellipsis | Fixed height or width on a text box | Remove the fixed size, or add `text-overflow: ellipsis` plus `white-space: nowrap` and a `title` with the full text |
| `overflowParent` | A child is wider than its parent | `min-width` on the child, flex items that cannot shrink | `min-width: 0` on flex and grid children, `flex-wrap: wrap` |
| `smallViews` | A map, chart, canvas, route view, or large SVG is smaller than its minimum (320x240 by default, or `data-ui-min="WxH"`) | A fixed `width`/`height` attribute, a flex column squeezed by its sibling, a parent with no height | `width: 100%`, `min-height`, `aspect-ratio`, a grid column with `minmax(0, 1fr)` and a minimum for the view column |
| `overlaps` | Two text elements cover each other | Absolute positioning, negative margins, labels on a chart without collision handling | Normal flow, or offset and halo for chart labels |
| `tinyText` (count, not a failure) | Text under 12px | Captions set too small | Raise to 12px or more |
| `unnamedButtons` (count, not a failure) | Buttons or links with no text, `aria-label`, or `title` | Icon-only buttons | Add `aria-label` in Korean |

The checks cover geometry only. Wrong hierarchy, poor contrast, misaligned numbers, and a view that is technically large enough but visually lost still need a person or an agent to look at the screenshot.

## States to shoot for every screen with data
Mock the API with the commands in `playwright-cli.md`, shoot, then `p unroute`.
| State | How | What it must show |
|---|---|---|
| Normal | Real API | Real data at all three viewports |
| Empty | `p route "**/api/<x>" --body '[]' --content-type application/json` | The table header, one line that says why it is empty, the next action |
| Loading | Delayed route through `run-code` | Layout kept, placeholder rows or a one-line message |
| Error | `p route "**/api/<x>" --status 500 --body '{"error":"x"}'` | A message that says what failed and a retry button. A previous result stays visible and is marked stale |
| Long data | Real data with the longest names, or a mocked body with 200 rows and a 40-character name | No overflow, ellipsis with a tooltip, the table scrolls inside its box |

Label the shots `U#-<state>` so the screenshot names say what they show.

## Locking a fix in
- Size: put `data-ui-min="WxH"` on the element. Every later shoot fails if it shrinks below that size.
- Overlap, clipping, and sideways overflow: already checked on every shoot at every viewport.
- Anything else (color, alignment, hierarchy): say in the E# that it was checked by screenshot only, with the before and after paths.
