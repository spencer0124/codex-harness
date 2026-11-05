#!/usr/bin/env node
// Usage: node .agents/skills/analyze/scripts/profile-data.mjs <file-or-dir>... > docs/analysis/DATA.md
// Profiles CSV, TSV, and JSON (array of objects) files as markdown. Node 20+, no dependencies.
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, isAbsolute } from 'node:path';
import { pathToFileURL } from 'node:url';

const DATA_EXT = new Set(['.csv', '.tsv', '.json']);
const NULL_TOKENS = new Set(['null', 'nan', 'n/a', 'na', 'none', '-']);
const EN_PAIRS = [['start', 'end'], ['begin', 'end'], ['from', 'to'], ['depart', 'arrive'], ['departure', 'arrival'], ['open', 'close'], ['in', 'out']];
const KO_PAIRS = [['시작', '종료'], ['시작', '끝'], ['출발', '도착']];
const KEY_TOKENS = new Set(['id', 'key', 'code', 'no']);
const WEEKDAYS = ['일', '월', '화', '수', '목', '금', '토'];
const LABEL = { integer: '정수', decimal: '소수', number: '숫자(정수+소수)', boolean: '참/거짓', date: '날짜', datetime: '날짜시각', time: '시각', text: '텍스트', baddate: '없는 날짜', empty: '빈 열' };
const DATE_RE = /^(\d{4})([-/.])(\d{1,2})\2(\d{1,2})(?:[T ](\d{1,2}):(\d{2})(?::(\d{2}))?(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?)?$/;
const KO_DATE_RE = /^(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일$/;
const TIME_RE = /^(\d{1,2}):(\d{2})(?::(\d{2}))?$/;

export function parseCsv(text, delim = ',') {
  const rows = [];
  let row = [], field = '', inQuote = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuote) {
      if (c !== '"') field += c;
      else if (text[i + 1] === '"') { field += '"'; i++; }
      else inQuote = false;
    } else if (c === '"' && field === '') inQuote = true;
    else if (c === delim) { row.push(field); field = ''; }
    else if (c === '\n' || c === '\r') {
      if (c === '\r' && text[i + 1] === '\n') i++;
      row.push(field); rows.push(row); row = []; field = '';
    } else field += c;
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row); }
  return { rows, unterminatedQuote: inQuote };
}

function decode(buf) {
  const bom = buf.length >= 3 && buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf;
  try { return { text: new TextDecoder('utf-8', { fatal: true }).decode(buf), encoding: 'UTF-8', bom }; }
  catch { return { text: new TextDecoder('euc-kr').decode(buf), encoding: 'EUC-KR', bom }; }
}

function sniffDelimiter(text, ext) {
  if (ext === '.tsv') return '\t';
  const first = text.slice(0, text.search(/\r?\n|$/));
  const best = [',', ';', '\t'].map((d) => [d, first.split(d).length - 1]).sort((a, b) => b[1] - a[1])[0];
  return best[1] > 0 ? best[0] : ',';
}

function parseDate(v) {
  let m = DATE_RE.exec(v), y, sep, mo, d, hh, mi, ss, fmt;
  if (m) {
    [, y, sep, mo, d, hh, mi, ss] = m;
    fmt = `YYYY${sep}${mo.length === 2 ? 'MM' : 'M'}${sep}${d.length === 2 ? 'DD' : 'D'}`;
  } else if ((m = KO_DATE_RE.exec(v))) {
    [, y, mo, d] = m;
    fmt = 'YYYY년 M월 D일';
  } else return null;
  const Y = +y, M = +mo, D = +d;
  const valid = M >= 1 && M <= 12 && D >= 1 && D <= new Date(Date.UTC(Y, M, 0)).getUTCDate();
  const iso = `${y}-${String(M).padStart(2, '0')}-${String(D).padStart(2, '0')}`;
  const hasTime = hh !== undefined;
  if (hasTime) fmt += ss !== undefined ? ' hh:mm:ss' : ' hh:mm';
  return { iso, fmt, valid, hasTime, sortKey: hasTime ? `${iso}T${hh.padStart(2, '0')}:${mi}:${ss ?? '00'}` : iso };
}

function timeMinutes(v) {
  const m = TIME_RE.exec(v);
  return m ? +m[1] * 60 + +m[2] + (m[3] ? +m[3] / 60 : 0) : null;
}

function classify(v) {
  if (/^[+-]?\d+$/.test(v)) return { type: 'integer', num: Number(v) };
  if (/^[+-]?\d{1,3}(,\d{3})+$/.test(v)) return { type: 'integer', num: Number(v.replace(/,/g, '')), thousands: true };
  if (/^[+-]?(\d+\.\d*|\.\d+)$/.test(v)) return { type: 'decimal', num: Number(v) };
  if (/^(true|false|yes|no)$/i.test(v)) return { type: 'boolean' };
  const date = parseDate(v);
  if (date) return { type: !date.valid ? 'baddate' : date.hasTime ? 'datetime' : 'date', date };
  const minutes = timeMinutes(v);
  if (minutes !== null) return { type: 'time', minutes };
  return { type: 'text' };
}

function tokens(name) {
  return name.replace(/([a-z0-9])([A-Z])/g, '$1 $2').toLowerCase().split(/[^a-z0-9가-힣]+/).filter(Boolean);
}

function keyLike(name) {
  return KEY_TOKENS.has(tokens(name).at(-1)) || /(번호|코드|아이디)$/.test(name);
}

function cell(v, max = 30) {
  const s = String(v).replace(/\s+/g, ' ').replace(/\|/g, '\\|');
  return s.length > max ? `${s.slice(0, max)}…` : s;
}

function profileColumn(name, values) {
  const c = { name, blank: 0, nullTok: 0, ws: 0, types: {}, counts: new Map(), nums: [], thousands: 0, dates: [], dateFmts: new Set(), times: [], past24: 0, lens: [] };
  for (const raw of values) {
    if (raw.trim() === '') { c.blank++; continue; }
    const v = raw.trim();
    if (v !== raw) c.ws++;
    if (NULL_TOKENS.has(v.toLowerCase())) { c.nullTok++; continue; }
    c.counts.set(v, (c.counts.get(v) || 0) + 1);
    c.lens.push(v.length);
    const k = classify(v);
    c.types[k.type] = (c.types[k.type] || 0) + 1;
    if (k.num !== undefined) c.nums.push(k.num);
    if (k.thousands) c.thousands++;
    if (k.date) { c.dateFmts.add(k.date.fmt); if (k.date.valid) c.dates.push(k.date); }
    if (k.minutes !== undefined) { c.times.push({ v, minutes: k.minutes }); if (k.minutes >= 1440) c.past24++; }
  }
  c.filled = values.length - c.blank - c.nullTok;
  const t = c.types;
  if (t.integer && Object.keys(t).length === 1 && c.counts.size && [...c.counts.keys()].every((v) => /^\d{8}$/.test(v) && parseDate(`${v.slice(0, 4)}-${v.slice(4, 6)}-${v.slice(6)}`)?.valid)) {
    c.types = { date: t.integer };
    c.nums = [];
    c.dateFmts = new Set(['YYYYMMDD']);
    c.dates = [...c.counts.keys()].flatMap((v) => Array(c.counts.get(v)).fill(parseDate(`${v.slice(0, 4)}-${v.slice(4, 6)}-${v.slice(6)}`)));
  }
  const ranked = Object.entries(c.types).sort((a, b) => b[1] - a[1]);
  c.primary = ranked.length ? ranked[0][0] : 'empty';
  if ((c.types.integer || 0) && (c.types.decimal || 0) && ['integer', 'decimal'].includes(c.primary)) c.primary = 'number';
  const family = c.primary === 'number' ? ['integer', 'decimal'] : [c.primary];
  c.others = ranked.filter(([k]) => !family.includes(k));
  c.decimals = c.types.decimal || 0;
  c.zeros = c.nums.filter((n) => n === 0).length;
  c.negatives = c.nums.filter((n) => n < 0).length;
  c.dupValues = [...c.counts.values()].filter((n) => n > 1).length;
  return c;
}

function minMax(c) {
  if (['integer', 'decimal', 'number'].includes(c.primary) && c.nums.length) return [Math.min(...c.nums), Math.max(...c.nums)];
  if (['date', 'datetime'].includes(c.primary) && c.dates.length) {
    const keys = c.dates.map((d) => d.sortKey).sort();
    return [keys[0], keys.at(-1)];
  }
  if (c.primary === 'time' && c.times.length) {
    const s = [...c.times].sort((a, b) => a.minutes - b.minutes);
    return [s[0].v, s.at(-1).v];
  }
  if (c.lens.length) return [`길이 ${Math.min(...c.lens)}`, `길이 ${Math.max(...c.lens)}`];
  return ['', ''];
}

function findPairs(header) {
  const pairs = [];
  header.forEach((a, i) => {
    const ta = tokens(a);
    for (const [s, e] of EN_PAIRS) {
      if (!ta.includes(s)) continue;
      const want = ta.map((t) => (t === s ? e : t)).join(' ');
      const j = header.findIndex((b, k) => k !== i && tokens(b).join(' ') === want);
      if (j >= 0) pairs.push([i, j]);
    }
    for (const [s, e] of KO_PAIRS) {
      if (!a.includes(s)) continue;
      const j = header.indexOf(a.replace(s, e));
      if (j >= 0 && j !== i) pairs.push([i, j]);
    }
  });
  return pairs;
}

function comparable(v) {
  const minutes = timeMinutes(v);
  if (minutes !== null) return { kind: 'time', key: minutes };
  const d = parseDate(v);
  return d && d.valid && d.hasTime ? { kind: 'datetime', key: d.sortKey } : null;
}

function profileTable(t) {
  const { display, header, rows, meta } = t;
  const flag = (col, text) => t.flags.push(`- \`${display}\`${col ? ` \`${col}\`` : ''}: ${text}`);
  const lines = [`## \`${display}\``, '', `- ${meta.join(', ')}`];
  const width = header.length;
  const ragged = rows.filter((r) => r.cells.length !== width);
  if (ragged.length) {
    lines.push(`- 열 수가 헤더와 다른 행: ${ragged.length}개 (예: 행 ${ragged.slice(0, 3).map((r) => r.n).join(', ')})`);
    flag('', `열 수가 헤더와 다른 행 ${ragged.length}개. 잘린 데이터인가, 값 안의 구분자인가?`);
  }
  const seen = new Map(), dups = [];
  for (const r of rows) {
    const key = r.cells.join('\u0001');
    if (seen.has(key)) dups.push(`행 ${r.n} (= 행 ${seen.get(key)})`); else seen.set(key, r.n);
  }
  if (dups.length) {
    lines.push(`- 완전히 같은 행: ${dups.length}개 (예: ${dups.slice(0, 3).join(', ')})`);
    flag('', `완전히 같은 행 ${dups.length}개. 중복으로 지우는가, 별개 항목으로 보는가?`);
  }
  const emptyHeaders = header.filter((h) => h.trim() === '').length;
  if (emptyHeaders) flag('', `이름이 빈 열 ${emptyHeaders}개.`);
  const dupHeaders = header.filter((h, i) => header.indexOf(h) !== i);
  if (dupHeaders.length) flag('', `열 이름 중복: ${[...new Set(dupHeaders)].join(', ')}.`);

  const cols = header.map((name, i) => profileColumn(name, rows.map((r) => r.cells[i] ?? '')));
  t.columns = cols;
  lines.push('', '| 열 | 타입 | 빈 값 | 고유값 | 최소 | 최대 | 비고 |', '|---|---|---|---|---|---|---|');
  for (const c of cols) {
    const [min, max] = minMax(c);
    const notes = [];
    if (c.nullTok) notes.push(`null 표기 ${c.nullTok}`);
    if (c.decimals && c.primary !== 'decimal') notes.push(`소수 ${c.decimals}`);
    if (c.zeros) notes.push(`0 값 ${c.zeros}`);
    if (c.negatives) notes.push(`음수 ${c.negatives}`);
    if (c.past24) notes.push(`24:00 이후 ${c.past24}`);
    if (c.others.length) notes.push(`섞인 타입: ${c.others.map(([k, n]) => `${LABEL[k]} ${n}`).join(', ')}`);
    if (c.counts.size === 1 && c.filled > 1) notes.push('모든 값이 같음');
    if (c.counts.size && c.counts.size <= 12 && c.filled > c.counts.size) {
      notes.push(`값: ${[...c.counts].sort((a, b) => b[1] - a[1]).map(([v, n]) => `${cell(v, 20)} ${n}`).join(', ')}`);
    }
    lines.push(`| \`${cell(c.name)}\` | ${LABEL[c.primary]} | ${c.blank} | ${c.counts.size} | ${cell(min)} | ${cell(max)} | ${notes.join('; ')} |`);

    if (c.primary === 'empty') { flag(c.name, '모든 값이 비어 있음. 쓰지 않는 열인가?'); continue; }
    if (c.blank) flag(c.name, `빈 값 ${c.blank}개. 거부할지, 경고하고 건너뛸지, 기본값을 쓸지?`);
    if (c.nullTok) flag(c.name, `null 표기(null, -, N/A 등) ${c.nullTok}개. 빈 값과 같은 뜻인가?`);
    if (c.ws) flag(c.name, `앞뒤 공백이 있는 값 ${c.ws}개. 공백을 지운 값과 같은 값으로 보는가?`);
    if (c.others.length) flag(c.name, `타입이 섞임 (${LABEL[c.primary]} 외에 ${c.others.map(([k, n]) => `${LABEL[k]} ${n}`).join(', ')}). 다른 타입 값은 오류인가?`);
    if (c.primary === 'number') flag(c.name, `정수와 소수가 섞임 (소수 ${c.decimals}개). 단위와 반올림 규칙은?`);
    if (c.zeros) flag(c.name, `0 값 ${c.zeros}개. 유효한 값인가, 누락을 뜻하나?`);
    if (c.negatives) flag(c.name, `음수 ${c.negatives}개. 허용되는가?`);
    if (c.thousands) flag(c.name, `천 단위 쉼표가 있는 숫자 ${c.thousands}개.`);
    if (c.types.baddate) flag(c.name, `날짜 형식이지만 없는 날짜 ${c.types.baddate}개.`);
    if (c.dateFmts.size > 1) flag(c.name, `날짜 형식이 섞임: ${[...c.dateFmts].join(', ')}.`);
    if (c.past24) flag(c.name, `24:00 이후 시각 ${c.past24}개. 다음 날로 보는가, 어느 날짜에 속하나?`);
  }

  for (const c of cols.filter((c) => c.dates.length)) {
    const days = [...new Set(c.dates.map((d) => d.iso))].sort();
    const ms = (iso) => Date.parse(`${iso}T00:00:00Z`);
    const span = Math.round((ms(days.at(-1)) - ms(days[0])) / 86400000) + 1;
    const byDay = Array(7).fill(0);
    for (const iso of days) byDay[new Date(ms(iso)).getUTCDay()]++;
    const months = new Set(days.map((d) => d.slice(0, 7)));
    lines.push('', `### 날짜 열 \`${cell(c.name)}\``, '',
      `- 범위 ${days[0]} ~ ${days.at(-1)} (${span}일 중 ${days.length}일 있음, 빠진 날짜 ${span - days.length}일, ${months.size}개월)`,
      `- 요일별 날짜 수: ${[1, 2, 3, 4, 5, 6, 0].map((i) => `${WEEKDAYS[i]} ${byDay[i]}`).join(', ')}`);
    if (byDay[0] + byDay[6]) flag(c.name, `주말 날짜 ${byDay[0] + byDay[6]}일 포함. 그날도 평일과 같은 규칙인가?`);
    if (span > days.length) flag(c.name, `${days[0]} ~ ${days.at(-1)} 사이에 빠진 날짜 ${span - days.length}일. 쉬는 날인가, 누락인가?`);
  }

  for (const [i, j] of findPairs(header)) {
    let compared = 0;
    const bad = [];
    for (const r of rows) {
      const a = comparable((r.cells[i] ?? '').trim()), b = comparable((r.cells[j] ?? '').trim());
      if (!a || !b || a.kind !== b.kind) continue;
      compared++;
      if (b.key < a.key) bad.push(r.n);
    }
    if (!compared) continue;
    lines.push('', `### 시각 쌍 \`${cell(header[i])}\` → \`${cell(header[j])}\``, '',
      `- 비교한 행 ${compared}개, 끝이 시작보다 이른 행 ${bad.length}개${bad.length ? ` (예: 행 ${bad.slice(0, 3).join(', ')})` : ''}`);
    if (bad.length) flag('', `\`${header[j]}\`이 \`${header[i]}\`보다 이른 행 ${bad.length}개. 자정을 넘는 경우인가, 오류인가? 어느 날짜에 속하나?`);
  }
  return lines.join('\n');
}

function csvTable(display, buf, ext) {
  const { text: raw, encoding, bom } = decode(buf);
  const text = raw.replace(/^﻿/, '');
  const delim = sniffDelimiter(text, ext);
  const { rows: records, unterminatedQuote } = parseCsv(text, delim);
  const crlf = text.includes('\r\n');
  const [header = [], ...body] = records;
  const rows = [];
  let empty = 0;
  body.forEach((cells, k) => {
    if (cells.length === 1 && cells[0].trim() === '') empty++; else rows.push({ n: k + 2, cells });
  });
  const meta = [`행 ${rows.length}개`, `열 ${header.length}개`, `구분자 \`${delim === '\t' ? '\\t' : delim}\``, `인코딩 ${encoding}`, bom ? 'BOM 있음' : 'BOM 없음', `줄바꿈 ${crlf ? 'CRLF' : 'LF'}`];
  if (empty) meta.push(`빈 줄 ${empty}개`);
  const t = { display, header, rows, meta, flags: [] };
  if (encoding !== 'UTF-8') t.flags.push(`- \`${display}\`: UTF-8이 아님 (EUC-KR로 읽음). 출력도 같은 인코딩이어야 하나?`);
  if (unterminatedQuote) t.flags.push(`- \`${display}\`: 닫히지 않은 따옴표가 있음. 파일이 잘렸을 수 있다.`);
  return [t];
}

function jsonTables(display, buf) {
  const data = JSON.parse(decode(buf).text.replace(/^﻿/, ''));
  const isRows = (v) => Array.isArray(v) && v.length > 0 && v.every((x) => x && typeof x === 'object' && !Array.isArray(x));
  const sets = isRows(data) ? [[display, data]] : data && typeof data === 'object' ? Object.entries(data).filter(([, v]) => isRows(v)).map(([k, v]) => [`${display}#${k}`, v]) : [];
  return sets.map(([name, items]) => {
    const header = [...new Set(items.flatMap((x) => Object.keys(x)))];
    const str = (v) => (v === null || v === undefined ? '' : typeof v === 'object' ? JSON.stringify(v) : String(v));
    const rows = items.map((x, k) => ({ n: k + 1, cells: header.map((h) => str(x[h])) }));
    return { display: name, header, rows, meta: [`항목 ${rows.length}개`, `키 ${header.length}개`, '행 번호 = 배열 순서(1부터)'], flags: [] };
  });
}

function collect(paths, cwd) {
  const files = new Map();
  const walk = (p, show) => {
    if (statSync(p).isDirectory()) {
      for (const e of readdirSync(p).sort()) if (!e.startsWith('.') && e !== 'node_modules') walk(join(p, e), show);
    } else if (DATA_EXT.has(extname(p).toLowerCase()) && !files.has(p)) files.set(p, show(p));
  };
  for (const root of paths) {
    const base = statSync(root).isDirectory() ? root : dirname(root);
    walk(root, (p) => {
      const r = relative(cwd, p);
      return r && !r.startsWith('..') && !isAbsolute(r) ? r : relative(base, p);
    });
  }
  return files;
}

function crossCheck(tables) {
  const flags = [];
  const byName = new Map();
  for (const t of tables) for (const c of t.columns ?? []) {
    if (!c.filled || !keyLike(c.name)) continue;
    if (!byName.has(c.name)) byName.set(c.name, []);
    byName.get(c.name).push({ t, c });
  }
  for (const [name, list] of byName) {
    const masters = list.filter(({ c }) => c.dupValues === 0);
    for (const { t, c } of list) {
      const others = masters.filter((m) => m.t !== t);
      if (c.dupValues && !others.length) flags.push(`- \`${t.display}\` \`${name}\`: 키처럼 보이지만 중복 값 ${c.dupValues}개. 같은 대상인가, 다른 대상인가?`);
      for (const m of others) {
        const missing = [...c.counts.keys()].filter((v) => !m.c.counts.has(v));
        if (missing.length) flags.push(`- \`${t.display}\` \`${name}\`: 값 ${missing.length}개가 \`${m.t.display}\` \`${name}\`에 없음 (예: ${missing.slice(0, 3).map((v) => cell(v, 20)).join(', ')}). 참조 오류인가?`);
      }
    }
  }
  return flags;
}

export function profilePaths(paths, cwd = process.cwd()) {
  const files = collect(paths, cwd);
  const tables = [], errors = [];
  for (const [f, name] of files) {
    try {
      const buf = readFileSync(f);
      const ext = extname(f).toLowerCase();
      const found = ext === '.json' ? jsonTables(name, buf) : csvTable(name, buf, ext);
      if (!found.length) errors.push(`- \`${name}\`: 객체 배열이 없어 표로 읽지 않음.`);
      tables.push(...found);
    } catch (err) {
      errors.push(`- \`${name}\`: 읽기 실패 (${cell(err.message, 80)}).`);
    }
  }
  const now = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const stamp = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}`;
  const out = ['# DATA', '',
    `\`node .agents/skills/analyze/scripts/profile-data.mjs ${paths.join(' ')}\`로 생성 (${stamp}). 파일 ${files.size}개, 표 ${tables.length}개.`,
    'CSV 행 번호는 헤더를 1로 센 레코드 번호다. 값 안에 줄바꿈이 없으면 파일 줄 번호와 같다.', ''];
  for (const t of tables) out.push(profileTable(t), '');
  const flags = [...errors, ...tables.flatMap((t) => t.flags), ...crossCheck(tables)];
  out.push('## 질문 후보', '', flags.length ? flags.join('\n') : '- 없음', '');
  return { markdown: out.join('\n'), files: files.size };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  if (!args.length) {
    console.error('usage: node profile-data.mjs <file-or-dir>...   (CSV, TSV, JSON)');
    process.exit(2);
  }
  const { markdown, files } = profilePaths(args);
  if (!files) { console.error(`no .csv, .tsv, or .json file under: ${args.join(' ')}`); process.exit(2); }
  process.stdout.write(markdown);
}
