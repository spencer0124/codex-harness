# Default stack

Use this stack unless README prescribes another. A deviation is a D#.

## Layout
One npm package, ESM, TypeScript strict.

| Path | Holds | Rule |
|---|---|---|
| `src/domain/` | types and pure functions: input parsing results, rules, the core algorithm, metrics | No I/O, no Express, no React. Data in, data out. |
| `src/server/` | `app.ts` (`createApp({ store, now })`), `main.ts` (listen), routes, `schemas.ts` (zod), `store.ts` | zod parses every request body and uploaded file before domain code sees it. |
| `src/web/` | `index.html`, `main.tsx`, `App.tsx`, `api.ts`, components | Talks to the server only through `api.ts`. Imports types from `src/domain/`. |
| `tests/` | `*.test.ts`: domain unit tests, route tests with supertest | Names start with the R#. |
| `data/` | input files the task ships | Read-only. |
| `var/` | runtime store (JSON files) | Created at boot. Tests pass a temp dir to `createApp`. |

`createApp` takes the store and a clock (`now`) as arguments, so route tests run against a temp dir and a fixed time.

## Dependencies
Install with `npm i -E` so versions are exact.

- Runtime: `express@5`, `zod`.
- Dev: `typescript`, `tsx`, `vite`, `@vitejs/plugin-react`, `react`, `react-dom`, `@types/node`, `@types/express`, `@types/react`, `@types/react-dom`, `vitest`, `supertest`, `@types/supertest`.
- CSV input: `csv-parse` (`csv-parse/sync`). Do not hand-roll quote handling.
- `playwright-cli` comes from `scripts/install-tools.sh`, not from `package.json`.

Anything else needs a one-line reason first (AGENTS.md section 1).

## One port: Express with Vite in middleware mode
The user opens one port in the web IDE preview. Express mounts the API routes first, then Vite's middleware in development or `dist/web` in production. One process, one port, same origin for `/api` (no proxy, no CORS, no process runner).

```ts
const app = createApp({ store: createStore('var'), now: () => new Date() });
const server = http.createServer(app);
if (process.env.NODE_ENV === 'production') {
	app.use(express.static('dist/web'));
	app.get('/{*splat}', (_req, res) => res.sendFile(path.resolve('dist/web/index.html')));
} else {
	const vite = await createViteServer({ root: 'src/web', appType: 'spa', server: { middlewareMode: true, hmr: { server } } });
	app.use(vite.middlewares);
}
const port = Number(process.env.PORT ?? 3000);
server.listen(port, '0.0.0.0', () => console.log(`listening on http://0.0.0.0:${port}`));
```

If the preview proxy blocks the HMR websocket, reload the page by hand. Nothing else depends on HMR.

## Config files
- `vite.config.ts`: `root: 'src/web'`, `plugins: [react()]`, `build.outDir: '../../dist/web'`, `build.emptyOutDir: true`.
- `vitest.config.ts` at the repo root, separate from `vite.config.ts` (whose root is `src/web`): `include: ['tests/**/*.test.ts', 'src/**/*.test.ts']`, `exclude: [...configDefaults.exclude, '.harness/**', '.study/**', '_workspace/**']`.
- `tsconfig.json`: `strict`, `module: "ESNext"`, `moduleResolution: "Bundler"`, `jsx: "react-jsx"`, `noEmit: true`, `types: ["node", "vite/client"]`, `include: ["src", "tests"]` so the harness files under `.agents/` and `scripts/` stay out of the typecheck.

## Scripts
```json
{
	"dev": "tsx watch --clear-screen=false src/server/main.ts",
	"start": "vite build && NODE_ENV=production tsx src/server/main.ts",
	"test": "vitest run",
	"typecheck": "tsc --noEmit",
	"check": "npm run typecheck && npm test"
}
```

`npm run dev` starts everything and prints the URL. If port 3000 is taken, run `PORT=3001 npm run dev`.

## Conventions
- Dates: a local date is a `YYYY-MM-DD` string. A local time is minutes from midnight, and a time after midnight that belongs to the previous day is a value above 1440. Do calendar math on those values, never on `Date` in the server's timezone.
- Numbers from input files: parse them at the boundary and reject or flag non-numeric, negative, or fractional values where a C# says integers.
- Draw diagrams, paths, and charts with plain SVG in React first. Add a drawing or map library only when a C# needs it, and log it as a D#.
- Styling follows the `ui` skill and `design/DESIGN.md`.
- No database server, ORM, auth library, or global state manager unless a C# needs one.
