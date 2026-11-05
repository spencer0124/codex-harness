// Usage: node --test .agents/skills/analyze/scripts/profile-data.selftest.mjs
// Named *.selftest.mjs so a workspace test runner (Vitest, Jest, node --test discovery) never picks it up.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { parseCsv, profilePaths } from './profile-data.mjs';

const SCRIPT = fileURLToPath(new URL('./profile-data.mjs', import.meta.url));
const dir = mkdtempSync(join(tmpdir(), 'profile-data-'));
const write = (name, content) => writeFileSync(join(dir, name), content);

write('main.csv', '﻿' + [
  'id,name,city,score,minutes,date,start_time,end_time',
  '1,Kim,"Seoul, KR",10,0,2026-03-02,08:00,09:00',
  '2,Lee,Busan,7.5,15,2026-03-03,23:30,00:40',
  '3,,Seoul,8,0,2026-03-07,09:00,10:00',
  '3,Park,Daegu,,20,2026-03-04,25:10,26:00',
  '4,Choi,"Seoul, KR",10,0,2026-03-02,08:00,09:00',
  '4,Choi,"Seoul, KR",10,0,2026-03-02,08:00,09:00',
].join('\r\n') + '\r\n');
write('master.csv', 'code,label\nA,x\nB,y\n');
write('usage.csv', 'code,qty\nA,1\nC,2\nC,3\n');
write('people.json', JSON.stringify([{ pid: 1, nick: 'a' }, { pid: 2, nick: null }]));
write('legacy.csv', Buffer.concat([Buffer.from('name\n'), Buffer.from([0xb0, 0xa1]), Buffer.from('\n')]));
write('notes.txt', 'ignored');

const { markdown: md, files } = profilePaths([dir]);

test('parseCsv keeps quoted commas, escaped quotes, and embedded newlines', () => {
  const { rows } = parseCsv('a,b,c\n"x, y","say ""hi""","two\nlines"\n', ',');
  assert.deepEqual(rows, [['a', 'b', 'c'], ['x, y', 'say "hi"', 'two\nlines']]);
});

test('reads only data files, strips the BOM, and reports CRLF', () => {
  assert.equal(files, 5);
  assert.match(md, /BOM 있음/);
  assert.match(md, /줄바꿈 CRLF/);
  assert.match(md, /\| `id` \| 정수 \|/);
  assert.doesNotMatch(md, /﻿/);
});

test('a quoted comma stays inside one value', () => {
  assert.match(md, /`city` \| 텍스트 \| 0 \| 4 \|/);
  assert.match(md, /Seoul, KR 3/);
});

test('flags blanks, mixed decimals, zeros, duplicate keys, and duplicate rows', () => {
  assert.match(md, /`main\.csv` `name`: 빈 값 1개/);
  assert.match(md, /`main\.csv` `score`: 정수와 소수가 섞임 \(소수 1개\)/);
  assert.match(md, /`main\.csv` `minutes`: 0 값 4개/);
  assert.match(md, /`main\.csv` `id`: 키처럼 보이지만 중복 값 2개/);
  assert.match(md, /완전히 같은 행: 1개 \(예: 행 7 \(= 행 6\)\)/);
});

test('profiles the date column: range, gaps, weekdays, weekend', () => {
  assert.match(md, /범위 2026-03-02 ~ 2026-03-07 \(6일 중 4일 있음, 빠진 날짜 2일, 1개월\)/);
  assert.match(md, /요일별 날짜 수: 월 1, 화 1, 수 1, 목 0, 금 0, 토 1, 일 0/);
  assert.match(md, /`date`: 주말 날짜 1일 포함/);
});

test('pairs start and end columns and counts end before start', () => {
  assert.match(md, /시각 쌍 `start_time` → `end_time`/);
  assert.match(md, /비교한 행 6개, 끝이 시작보다 이른 행 1개 \(예: 행 3\)/);
  assert.match(md, /`start_time`: 24:00 이후 시각 1개/);
});

test('flags references missing from a unique key column in another file', () => {
  assert.match(md, /`usage\.csv` `code`: 값 1개가 `master\.csv` `code`에 없음 \(예: C\)/);
  assert.doesNotMatch(md, /`usage\.csv` `code`: 키처럼 보이지만/, 'a reference column may repeat values');
  assert.doesNotMatch(md, /`name`: 값 \d+개가/, 'non-key columns are not cross-checked');
});

test('reads JSON arrays of objects and EUC-KR files', () => {
  assert.match(md, /people\.json` `nick`: 빈 값 1개/);
  assert.match(md, /legacy\.csv`: UTF-8이 아님 \(EUC-KR로 읽음\)/);
  assert.match(md, /인코딩 EUC-KR/);
});

test('CLI prints markdown, and exits 2 without arguments', () => {
  const ok = spawnSync(process.execPath, [SCRIPT, dir], { encoding: 'utf8' });
  assert.equal(ok.status, 0);
  assert.match(ok.stdout, /^# DATA/);
  const none = spawnSync(process.execPath, [SCRIPT], { encoding: 'utf8' });
  assert.equal(none.status, 2);
});
