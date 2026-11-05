# Korean UI copy

The audience is an operator at work. Copy is short, concrete, and the same everywhere.

## Rules
- Labels and table headers are nouns: "처리 건수", "담당자", "마감 시각". Add the unit in parentheses: "소요 시간(분)".
- Buttons are the action as a noun phrase or a short verb: "계획 생성", "적용", "다시 시도", "JSON 내보내기". One word per action across the whole app.
- Sentences use 합니다체 for notices and errors, 해요체 nowhere, and never mix the two.
- An error says what failed and what to do: "데이터 적용에 실패했습니다. 파일 형식을 확인한 뒤 다시 시도하세요." Name the field when a field is wrong.
- An empty state says why it is empty and what to do: "아직 생성한 계획이 없습니다. 조건을 입력하고 계획 생성을 누르세요."
- Numbers: thousands separators, fixed decimals per column, units next to the number.
- Times and dates in one format everywhere: `2026-11-05`, `07:40`. A time after midnight that belongs to the previous service day shows the day: `(익일) 00:30`.
- Use the stakeholder's own words for domain terms (from `docs/analysis/CONDITIONS.md`), not synonyms.

## Words that read as machine-written in a UI
Cut them or replace them with the concrete fact: "효율적인", "다양한", "손쉽게", "스마트한", "최적의", "원활한", "~를 통해", "~할 수 있습니다" on a button or label, exclamation marks, emoji, and English filler such as "Seamless" or "Powerful".

## Humanize pass
After a unit adds copy, collect the new Korean strings into one block and run `$humanize-korean` on it in light mode. It writes under `_workspace/` (gitignored). Apply only edits that keep the meaning and the length budget of the element. Labels and button text rarely need it. Notices, empty states, errors, and help text usually do.
