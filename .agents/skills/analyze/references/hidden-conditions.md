# Hidden-condition probes

Walk every category for every task. A category that does not apply goes under "Skipped categories" in QUESTIONS.md with a one-line reason.

Ask each topic in three layers, as separate questions:

1. Is there? "…가 있나요?"
2. What is the rule? Exact value, unit, and whether the boundary is included. "…는 정확히 어떻게 정하나요? 경계값은 포함인가요?"
3. What are the exceptions? Who, which day, which data. "…를 따르지 않는 사람이나 날, 데이터가 있나요?"

Close every category with: "<주제>에 관해 그 밖에 따로 처리해야 하는 경우가 있나요?"

Ask every P0 fact twice: once as a rule and once as a concrete example. "마감은 도착 기준인가요?" and "마감이 09:00이면 09:00 정각 도착은 통과인가요?" If the two answers disagree, an exception exists. Ask about it.

## Calendar
- Holidays and non-working days: is there a list, is it in the data, and what changes on those days.
- Recurring special days: month-end, the first or last given weekday of a month, weekly or monthly events, seasonal schedules. "매주 또는 매달 정해진 날에 평소와 다르게 운영하는 날이 있나요?"
- Period boundaries: are the start and end dates included, which timezone, and what happens when the period starts or ends mid-week.
- The day after the period ends: work or events that start inside the period and end after it. Outputs that need the following day.
- Combinations, each asked as a concrete example: a span that crosses midnight on the period's last day, or into a day with other rules (a weekend, a holiday, a special day). A special day on the first or last day. An entity that is absent on a special day.
- Week definition and date formats in input and output.

## Time
- Spans that cross midnight: how the data stores them (25:00, a next-day date, end earlier than start) and which day they belong to.
- Deadlines: arrive by, start after, finish before. Is the boundary inclusive?
- Slack or buffer: minimum, maximum, fixed or per case, and who sets it.
- Units and rounding: minutes or seconds, decimals, zero durations, round up, down, or to nearest, and the display format.
- Durations between places or steps: symmetric or not, dependent on time of day, and what to do when a pair is missing.

## People and entities
- Availability: days off, leave, partial days, and changes during the period.
- Individual exceptions: someone who cannot use an option, needs a specific one, or has a fixed assignment.
- Groups: who belongs to which group, whether one entity can be in two groups, and whether membership changes during the period.
- Identity: the unique key, the same entity listed twice, renamed entities.

## Capacity and limits
- Maximum per unit, minimum needed to run, number of resources, maximum count per day, maximum duration or distance.
- Demand above capacity: split, reject, overflow to the next unit, or warn.
- Which limits are hard (never break) and which are soft (break with a warning or a penalty).

## Data quality
- Per field: what counts as invalid. Missing, blank, duplicate, a decimal where an integer is expected, zero, negative, out of range, an unknown code, a date that does not exist.
- Handling: reject the whole file, skip the row with a warning, or repair it with a default. Is the user shown what was skipped or repaired?
- Two sources that disagree: which one wins. Several data sets or versions: can the user switch, and what happens to results made from the old one.
- Encoding and header expectations for input files.

## Rules in conflict
- When two rules cannot both hold, which wins: a strict order or a trade-off with weights.
- When no result satisfies every hard rule: fail, return a partial result, or relax a named rule.

## Success definition
- What a good result is: the metric, its exact definition, its unit, whether lower or higher is better, and the baseline to compare against.
- Who judges the result and what they look at first. In a fab, ask which number they watch daily (throughput, moves, utilization, TAT) and put it first on the result screen.
- How the work is done today (FIFO, a fixed cycle, a spec-only check, a spreadsheet), with enough detail to reproduce it on the data. A new tool gets used only when it clearly beats that and needs no setup.
- When two measures conflict, which gives way. Offer a default to confirm: the one with less effect on output.
- Ties between equal results, and whether the same input must always give the same output.
- Whether a rule-based result is acceptable or an optimized one is expected, and whether the choice must be explainable to the user.

## Operations
- Who uses it, how many at once, and which roles may change what.
- Regenerate: replace the previous result, keep a history, or allow rollback. What the screen shows while it runs.
- Failure part-way through generating or applying: keep the previous result, keep a partial one, or show an error only.
- Two users who generate or apply at the same time.
- Inputs that change after a result exists: invalidate it, mark it stale, or keep it.
- Persistence: must results survive a restart.

## Outputs
- Export formats, exact field names, order, encoding, and file name.
- Required screens, views, filters, and warnings the user must see.
- Language, number format, and date format on screen.
- Is there a sample of the expected output?

## API and security
- Authentication, roles, and which endpoints change state.
- Required headers, CORS, and cross-site request protection.
- Input size limits, rate limits, and the error format the client expects.

## Closing questions for every round
- "지금까지 말씀하신 것 말고, 평소와 다르게 처리해야 하는 날이나 사람, 데이터가 있나요?"
- "이 결과를 실제로 쓰는 분이 가장 먼저 확인하는 것은 무엇인가요?"
- "예전에 비슷한 작업에서 문제가 됐던 경우가 있나요?"
