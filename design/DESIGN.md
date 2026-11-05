---
version: alpha
name: SK-hynix-operations-console
description: A corporate, data-first interface adapted from skhynix.com for an internal operations dashboard. Near-black ink on white, square corners everywhere, tables framed by a heavy 2px top rule, and one hot orange used only as the "you are here" indicator (active nav, active tab). Interaction hover is indigo. No gradients, no card shadows, no rounded panels.

colors:
  ink: "#212121"
  ink-2: "#3e3e3e"
  body: "#666666"
  muted: "#888888"
  muted-2: "#999999"
  subtle: "#bdbdbd"
  canvas: "#ffffff"
  surface-alt: "#f5f5f5"
  surface-strong: "#333333"
  line-strong: "#212121"
  line: "#e5e5e5"
  line-control: "#dddddd"
  accent: "#ff6600"
  accent-strong: "#ff5a00"
  interactive: "#4747b3"
  violet: "#5c51d6"
  logo-red: "#d6001f"
  logo-orange: "#ed6900"
  status-ok: "#069e6d"
  status-warn: "#fda744"
  status-error: "#d10025"
  status-info: "#4747b3"
  data-up: "#d10025"
  data-down: "#2b65d9"
  on-dark: "#ffffff"

typography:
  font-stack: "Roboto, 'Noto Sans KR', system-ui, -apple-system, 'Apple SD Gothic Neo', sans-serif"
  display:
    fontSize: 64px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: 0
  page-title:
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: -0.02em
  section-title:
    fontSize: 20px
    fontWeight: 700
    lineHeight: 30px
    letterSpacing: -0.4px
  nav:
    fontSize: 18px
    fontWeight: 400
    letterSpacing: -0.36px
  tab:
    fontSize: 20px
    fontWeight: 400
    lineHeight: 64px
  tab-active:
    fontSize: 20px
    fontWeight: 700
    lineHeight: 64px
  body:
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: -0.32px
  body-strong:
    fontSize: 16px
    fontWeight: 700
    lineHeight: 1.5
  body-sm:
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  kpi-value:
    fontSize: 32px
    fontWeight: 400
    lineHeight: 1.2
    fontVariantNumeric: tabular-nums
  kpi-label:
    fontSize: 16px
    fontWeight: 400
  caption:
    fontSize: 12px
    fontWeight: 400
    lineHeight: 18px

rounded:
  none: 0
  xs: 3px
  full: 9999px

spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  3xl: 64px
  gutter-desktop: 112px
  content-max: 1216px

components:
  app-header:
    height: 64px
    backgroundColor: "{colors.canvas}"
    borderBottom: "1px solid {colors.line}"
  nav-link-active:
    indicator: "4px {colors.accent} bar on the header's bottom edge"
  breadcrumb:
    typography: "{typography.body-sm}"
    textColor: "{colors.body}"
  tab-bar:
    borderBottom: "1px solid {colors.line}"
    indicator: "4px {colors.accent-strong}"
  segmented-control:
    backgroundColor: "{colors.surface-alt}"
    border: "1px solid {colors.line-control}"
    selectedBackground: "{colors.surface-strong}"
    selectedText: "{colors.on-dark}"
    rounded: "{rounded.none}"
  kpi-strip:
    backgroundColor: "{colors.surface-alt}"
    borderBottom: "1px solid {colors.line-strong}"
  data-table:
    borderTop: "2px solid {colors.line-strong}"
    headerBorderBottom: "1px solid {colors.line-strong}"
    cellBorder: "1px solid {colors.line}"
    cellPadding: "24px 16px"
    denseCellPadding: "16px 8px"
    rowHeaderBackground: "{colors.surface-alt}"
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.on-dark}"
    height: 48px
    padding: "12px 24px"
    rounded: "{rounded.none}"
  button-outline:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    border: "1px solid {colors.line-control}"
    height: 48px
    padding: "12px 50px 12px 16px"
    rounded: "{rounded.none}"
  input:
    height: 48px
    border: "1px solid {colors.line-control}"
    focusBorder: "1px solid {colors.ink}"
    focusRing: "2px solid {colors.interactive}"
    rounded: "{rounded.none}"
  status-badge:
    height: 24px
    padding: "0 8px"
    rounded: "{rounded.xs}"
  map-view:
    backgroundColor: "{colors.canvas}"
    border: "1px solid {colors.line}"
    minSize: "320x240"
  floating-control:
    rounded: "{rounded.full}"
    shadow: "0 4px 6px rgba(0, 0, 0, 0.1)"
---

## Overview

skhynix.com reads like an annual report set on screen: near-black headlines, gray body copy, white space, and tables that carry the content. The site is built from square boxes and thin rules. Color is almost absent. The one loud color, a pure orange (`{colors.accent}` #ff6600), appears only as a 4px bar under the active top-nav item and the active tab. Hover and keyboard focus turn text indigo (`{colors.interactive}` #4747b3).

This file adapts that language to an operations console: forms that set conditions, a table of results, a map or route view, KPIs, and status. The adaptation keeps the site's three habits: square corners, rules instead of shadows, and orange only for "selected". Values marked (measured) come from computed styles and the site CSS on 2026-11-05. Values marked (adapted) have no counterpart on the site and follow the same habits.

**Key characteristics:**
- Ink `{colors.ink}` for headings and table headers, gray `{colors.body}` for running text. Two text tones carry the hierarchy, not color.
- Square corners on tables, buttons, inputs, tiles, and tabs. Round shapes are only for circular icon buttons and toggles.
- Tables open with a 2px ink rule on top and a 1px ink rule under the header row. Inner cell lines are light `{colors.line}`.
- Orange marks position: the active nav item, the active tab, the selected route. It never fills a button or a panel.
- No gradients, no card shadows. A shadow appears only on a control that floats above the page.

## Colors

> Source pages: home, IR financial info (credit ratings table), IR library (tabs, list, download button), stock info (KPI strip, period selector, chart). The CSS tally covers `common.css`, `sub.css`, `global.css`, `add.css`, `main.css` (version 2026.10.26.1).

### Text
- **Ink** (`{colors.ink}` #212121, measured, 268 uses in CSS): headings, nav, table headers, values in KPI tiles.
- **Ink 2** (`{colors.ink-2}` #3e3e3e, measured): text in row-header cells.
- **Body** (`{colors.body}` #666666, measured): running text, table cells, breadcrumb.
- **Muted** (`{colors.muted}` #888888 and `{colors.muted-2}` #999999, measured): captions, footer, secondary metadata.
- **Subtle** (`{colors.subtle}` #bdbdbd, measured): disabled text, placeholder.

### Surfaces and rules
- **Canvas** (`{colors.canvas}` #ffffff, measured): page and table background.
- **Surface alt** (`{colors.surface-alt}` #f5f5f5, measured): row-header cells, the KPI strip, unselected segments.
- **Surface strong** (`{colors.surface-strong}` #333333, estimated from the stock page): the selected segment of a segmented control.
- **Line strong** (`{colors.line-strong}` #212121, measured): table top rule (2px), header bottom rule (1px), KPI strip bottom rule.
- **Line** (`{colors.line}` #e5e5e5, measured, 128 uses): table cell borders, tab-bar baseline, header bottom border.
- **Line control** (`{colors.line-control}` #dddddd, measured): borders of buttons and inputs.

### Accent and interaction
- **Accent** (`{colors.accent}` #ff6600, measured): the 4px active indicator under the top nav. Use it for "selected" and "current" only.
- **Accent strong** (`{colors.accent-strong}` #ff5a00, measured): the active-tab underline and active-tab text in outlined tabs.
- **Interactive** (`{colors.interactive}` #4747b3, measured): hover and focus text in menus, inline links (`.txt_blue`), the focus ring (adapted).
- **Violet** (`{colors.violet}` #5c51d6, measured): the site's floating social dock and the focus frame on news cards. Use at most once, for a floating control.

### Logo colors
- **Logo red** (`{colors.logo-red}` #d6001f) and **logo orange** (`{colors.logo-orange}` #ed6900), sampled from the official logo PNG. They belong to the logo. Do not build UI chrome from them.

### Status and data (adapted)
The site CSS contains these hues, but their roles here are ours.
- `{colors.status-ok}` #069e6d, `{colors.status-warn}` #fda744, `{colors.status-error}` #d10025, `{colors.status-info}` #4747b3.
- Korean market convention on the stock page: up is red, down is blue (`{colors.data-up}`, `{colors.data-down}`). The site offers a color-blind mode on that chart, so never let color alone carry a state. Pair it with a label, an icon, or a sign.
- Categorical series (routes, vehicles), in order: `#ff6600`, `#4747b3`, `#069e6d`, `#2b65d9`, `#fda744`, `#5c51d6`, then `#212121`. Past seven series, add dashes or labels instead of new hues.

### Gradients
None. The home hero uses photography. Do not add decorative gradients.

## Typography

### Font family
The site uses Roboto for Latin and digits, and a self-hosted Noto Sans KR (`NotoSanskr`, weights 300, 400, 500, 700) for Korean (measured). Use `{typography.font-stack}`. Loading Noto Sans KR from Google Fonts is optional. Without it, the stack falls back to Apple SD Gothic Neo or the system Korean font, which is close enough for a dashboard.

### Hierarchy
| Token | Size, weight, line height | Use | Source |
|---|---|---|---|
| `display` | 64px, 700, 1.3 | One landing heading per page, if any | measured (`.tit_type`) |
| `page-title` | 32px, 700, 1.3 | Dashboard page title | adapted: 64px eats a dashboard's first screen |
| `section-title` | 20px, 700, 30px, -0.4px | Section headings above tables and forms | measured (`.tit_type02`) |
| `nav` | 18px, 400, -0.36px | Top navigation | measured |
| `tab`, `tab-active` | 20px, 400 or 700, 64px line | Tab bar | measured (`.tab_menu`) |
| `body` | 16px, 400, 1.5, -0.32px | Text, table cells | measured |
| `body-sm` | 14px, 400, 1.5 | Dense tables, helper text, labels | measured (most common size in CSS) |
| `kpi-value` | 32px, 400, tabular figures | KPI numbers | estimated from the stock page |
| `caption` | 12px, 400, 18px | Footnotes, units | measured (copyright) |

### Principles
- Two weights do the work: 400 and 700. Use 500 only for a short emphasis inside a 400 run.
- Letter spacing is slightly negative (about -0.02em) at 16px and above. Keep it 0 at 14px and below.
- Numbers in tables and KPIs use `font-variant-numeric: tabular-nums` so columns line up.
- Korean line breaks: set `word-break: keep-all` on headings and table cells so words do not split mid-syllable-block.

## Layout

### Spacing system
4, 8, 16, 24, 32, 48, 64px. Table cells use 24px by 16px (dense: 16px by 8px). Buttons and inputs are 48px tall (measured).

### Grid and container
At 1440px the site's content column is 1216px wide with 112px side gutters (measured). For a dashboard use a 1216px max width, 32px gutters from 1280px down, and 16px gutters on phones. Put the condition form and the result side by side at 1280px and wider (form 360 to 400px, result the rest). Stack them below 1024px.

### Whitespace
The site separates sections with large empty space (192px above section titles). A dashboard cannot afford that. Use 48px between sections and 24px between a section title and its content, and keep the site's habit of rules over boxes.

## Elevation and depth

Flat. Tables, tiles, and panels have no shadow (measured: the site CSS declares box-shadow on eight rules, all on floating elements or popups).
- Floating controls (back-to-top, a floating toolbar): `0 4px 6px rgba(0, 0, 0, 0.1)` (measured on the social dock).
- Modal dialogs: a `rgba(0, 0, 0, 0.5)` scrim (present in site CSS) and a square white panel, no shadow needed.

## Shapes

### Border radius
- `{rounded.none}` for nearly everything (measured on tables, buttons, tabs, tiles).
- `{rounded.xs}` (3px) for small status badges only (3px is the most common non-zero radius in site CSS).
- `{rounded.full}` for circular icon buttons, toggle tracks, and map markers.

## Components

### Navigation
**`app-header`** (adapted from the site header): white, 64px tall (the site uses 82px), 1px `{colors.line}` bottom border. Logo on the left at 66 by 36 CSS px, nav links in `{typography.nav}`, actions on the right. The active link gets a 4px `{colors.accent}` bar on the header's bottom edge, animated with `transform: scaleX(0 to 1)` over 0.3s (measured).

**`breadcrumb`**: `{typography.body-sm}` in `{colors.body}`, chevron separators, sits 14px below the header.

### Tabs and selectors
**`tab-bar`** (measured, `.tab_menu`): text tabs in `{typography.tab}` on a 1px `{colors.line}` baseline. The active tab is 700 weight with a 4px `{colors.accent-strong}` underline. 32 to 48px between tabs. No boxes around tabs.

**`segmented-control`** (estimated from the stock page period selector): a row of square cells, `{colors.surface-alt}` fill, 1px `{colors.line-control}` borders, `{typography.body}` labels. The selected cell is `{colors.surface-strong}` with white text. Use it for modes and periods, two to seven options.

### Data
**`data-table`** (measured, `.tbl_data_list`): 2px `{colors.line-strong}` top rule. Header cells in `{typography.body-strong}`, `{colors.ink}`, centered, with a 1px `{colors.line-strong}` bottom rule. Body cells in `{typography.body}`, `{colors.body}`, 1px `{colors.line}` top and right borders, padding 24px by 16px. Row-header cells use `{colors.surface-alt}` and `{colors.ink-2}`. Dense variant at `{typography.body-sm}` with 16px by 8px padding. Numbers align right in a dashboard table (the site centers them; right alignment reads better for comparison). Wide tables scroll inside their own container with `overflow-x: auto`. The page itself never scrolls sideways.

**`kpi-strip`** (estimated from the stock page): one row of equal tiles on `{colors.surface-alt}`, separated by 1px `{colors.line}` verticals, closed by a 1px `{colors.line-strong}` bottom rule. Each tile: label in `{typography.kpi-label}` `{colors.body}`, value in `{typography.kpi-value}` `{colors.ink}`, unit in `{typography.caption}`. Four tiles at desktop, two per row on phones.

**`status-badge`** (adapted): 24px tall, 3px radius, 12 to 14px text, a light tint of the status color as fill and the full color as text, plus a word ("정상", "지연", "오류"). Never a colored dot alone.

**`map-view`** (adapted): the route or map panel. White canvas, 1px `{colors.line}` frame, fills its column: `width: 100%`, `min-height: 320px` (at least 240px on phones), `aspect-ratio` set from the data bounds. Never give it a fixed small pixel size. The selected route is `{colors.accent}` at 3 to 4px; other routes use the categorical series at 2px. Stops are `{rounded.full}` markers with a white 2px outline. Labels sit on a white halo so lines do not cross the text. Give the panel `data-ui-min="320x240"` so the `ui` skill's checks enforce the minimum.

### Buttons
**`button-primary`** (adapted): `{colors.ink}` fill, white text, 48px tall, square. One per view, for the main action (for example "계획 생성"). Pressed state `{colors.surface-strong}`. Disabled: `{colors.surface-alt}` fill, `{colors.subtle}` text.

**`button-outline`** (measured, `.btn_base`): white fill, 1px `{colors.line-control}` border, `{colors.ink}` text in `{typography.body}`, 48px tall, square, padding 12px 50px 12px 16px with a trailing icon (download, print, chart). Use it for secondary actions such as export.

**`floating-control`** (measured): circular, white, the floating shadow. On hover the back-to-top button fills with `{colors.accent-strong}`.

### Inputs and forms (adapted, not surfaced on the analyzed pages)
**`input`**, select, and date fields: 48px tall, square, 1px `{colors.line-control}` border, `{typography.body}`. Focus: border `{colors.ink}` plus a 2px `{colors.interactive}` outline with 2px offset. Labels above the field in `{typography.body-sm}` 700 `{colors.ink}`. Helper and error text below in `{typography.body-sm}`. Error text and border use `{colors.status-error}` and the message says what to change.

**Toggle** (seen on the stock page, estimated): pill track `{colors.line-control}`, white knob, on state `{colors.ink}` track. Label on the left.

### States
- **Loading**: keep the layout, show the table header and gray placeholder rows, or a one-line "불러오는 중" under the section title. The site shows a text "Loading…" with a chevron in the list footer.
- **Empty**: the table header stays. One line in `{colors.body}` says why it is empty and what to do next, with the primary action next to it.
- **Error**: a full-width box with a 1px `{colors.status-error}` left rule (4px), the message, and a retry button. Keep the last good result visible and mark it stale when the new request failed.

### Footer
Optional in a dashboard. If present: `{colors.surface-alt}` band, `{typography.caption}` in `{colors.muted}`.

### Logo
Run `bash scripts/fetch-logo.sh` at the start. It saves, under `src/web/public/brand/` (served at `/brand/`):
- `skhynix-logo.png`: the color logo, a 2x asset of 132 by 72 px. Show it at 66 by 36 CSS px on white or `{colors.surface-alt}`.
- `skhynix-logo-white.png` (140 by 77 px) and `skhynix-logo-white.svg`: the white logo for dark surfaces.
Keep the aspect ratio, leave clear space of at least half the logo height around it, and never recolor, outline, rotate, or put it on a busy background. Use `alt="SK hynix"`.

## Do's and don'ts

### Do
- Frame every table with the 2px ink top rule and the 1px ink header rule.
- Keep corners square on panels, tables, buttons, and inputs.
- Use `{colors.accent}` for "selected" and "current": the active nav item, the active tab, the selected route.
- Write numbers in tabular figures with units in a smaller, muted style.
- Use hover and focus in `{colors.interactive}` and make every focus state visible.
- Put wide tables in their own horizontal scroller.

### Don't
- Don't fill buttons or panels with orange. Orange is a marker, not a surface.
- Don't add shadows to cards, tables, or tiles.
- Don't round panels or buttons. A rounded card reads as a different brand.
- Don't use gradients, glassmorphism, or colored section backgrounds.
- Don't use red and blue alone to mean up and down, or green and red alone to mean OK and error. Add a word or a sign.
- Don't use the logo colors for UI elements.
- Don't use all-caps English labels or eyebrow labels over Korean headings.

## Responsive behavior

### Breakpoints (from the site CSS: 1500, 1280, 1024, 820, 768, 540, 350)
| Name | Width | Changes |
|---|---|---|
| Wide | 1280px and up | Form and result side by side. KPI strip in one row of four. |
| Laptop | 1024 to 1279px | Form narrows to 320px or stacks above the result. Tables switch to the dense variant. |
| Tablet | 768 to 1023px | Single column. Tab bar scrolls horizontally. Map view full width, at least 320px tall. |
| Phone | below 768px | 16px gutters. KPI tiles two per row. Header shows the logo and a menu button. Tables scroll horizontally inside their container. |

### Touch targets
Buttons and inputs are 48px tall (measured), which covers the 44px minimum. Icon-only buttons are at least 44 by 44px with an `aria-label`.

## Iteration guide
1. Build one component at a time and name its token key (`{component.data-table}`).
2. Use `{token.refs}` in CSS custom properties. Never inline a hex value in a component.
3. After each visual change, run the `ui` skill's `shoot.sh` at all three viewports and read the screenshots.
4. When unsure, remove a box, a color, or a shadow before adding one.

## Known gaps
- Form fields, selects, date pickers, toasts, and validation states do not appear on the analyzed pages. Their specs here are adapted.
- The KPI strip sizes, the segmented-control fill colors, and the toggle colors are estimated from screenshots, not computed styles.
- The site publishes no downloadable brand guideline on its Brand page, so logo clear-space and misuse rules here follow common practice, not an official document.
- Hover states other than the indigo text color, and dark mode, were not analyzed. The site ships a light theme only.
