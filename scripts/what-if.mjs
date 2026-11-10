#!/usr/bin/env node
// Usage: npx tsx scripts/what-if.mjs <entry module> <scenarios.json>   (plain `node` works when the entry is .mjs)
// The entry exports run(params), sync or async, returning { metricName: number }.
// scenarios.json: { "base": { ...params }, "variants": { "name": { ...top-level overrides } } }
// Prints a markdown table, one row per scenario, each metric with its delta against base, then `ms`: that row's run time. Exit 1 if any run failed, 2 on bad usage.
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const [entryArg, scenariosArg] = process.argv.slice(2);
if (!entryArg || !scenariosArg) {
  console.error('usage: npx tsx scripts/what-if.mjs <entry module> <scenarios.json>');
  process.exit(2);
}

const mod = await import(pathToFileURL(path.resolve(entryArg)).href);
const run = mod.run ?? mod.default?.run;
if (typeof run !== 'function') {
  console.error(`${entryArg} must export run(params)`);
  process.exit(2);
}

const { base, variants = {} } = JSON.parse(await readFile(scenariosArg, 'utf8'));
if (!base || typeof base !== 'object') {
  console.error(`${scenariosArg} needs a "base" object`);
  process.exit(2);
}

async function execute(name, overrides) {
  const params = { ...structuredClone(base), ...structuredClone(overrides) };
  try {
    const t0 = performance.now();
    const metrics = await run(params);
    const ms = performance.now() - t0;
    if (!metrics || typeof metrics !== 'object') throw new Error('run() must return an object of numbers');
    for (const [k, v] of Object.entries(metrics)) {
      if (typeof v !== 'number') throw new Error(`metric "${k}" is ${typeof v}, not a number`);
    }
    return { name, overrides, metrics, ms };
  } catch (err) {
    return { name, overrides, error: err instanceof Error ? err.message : String(err) };
  }
}

const rows = [await execute('base', {})];
for (const [name, overrides] of Object.entries(variants)) rows.push(await execute(name, overrides));

const keys = [...new Set(rows.flatMap((r) => Object.keys(r.metrics ?? {})))];
const fmt = (n) => (Number.isInteger(n) ? String(n) : String(Number(n.toFixed(3))));
const delta = (v, b) => {
  if (typeof b !== 'number' || !Number.isFinite(v) || !Number.isFinite(b)) return '';
  const d = v - b;
  return d === 0 ? ' (±0)' : ` (${d > 0 ? '+' : ''}${fmt(d)})`;
};
const cell = (s) => String(s).replaceAll('|', '\\|');

const baseMetrics = rows[0].metrics;
const lines = [
  `what-if: ${entryArg} · ${rows.length} scenarios · ${new Date().toTimeString().slice(0, 5)}`,
  '',
  `| scenario | changed | ${[...keys, 'ms'].join(' | ')} |`,
  `|${' --- |'.repeat(keys.length + 3)}`,
];
for (const r of rows) {
  const changed = r.name === 'base' ? '-' : cell(JSON.stringify(r.overrides));
  const values = r.error
    ? [cell(`error: ${r.error}`), ...Array(keys.length).fill('')]
    : [
        ...keys.map((k) => (k in r.metrics ? fmt(r.metrics[k]) + (r.name === 'base' ? '' : delta(r.metrics[k], baseMetrics?.[k])) : '')),
        r.ms.toFixed(1),
      ];
  lines.push(`| ${r.name} | ${changed} | ${values.join(' | ')} |`);
}
console.log(lines.join('\n'));
process.exit(rows.some((r) => r.error) ? 1 : 0);
