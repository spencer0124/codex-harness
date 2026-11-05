# Stateful defaults

Every action that changes stored state (apply a dataset, change conditions, generate a result) gets these defaults unless a C# says otherwise. In `$plan`, each default that applies becomes an R# whose source is an A# ("기본 설계: <default>"), so it carries an acceptance criterion and a test like any other requirement.

## The stored envelope
Each stored thing (current dataset, current conditions, current result) is one JSON file holding:

```ts
type Stored<T> = {
	version: number;      // +1 on every successful write
	inputHash: string;    // sha256 of the canonical JSON of what produced it (dataset version + conditions)
	status: 'current' | 'stale';
	staleReason?: string; // e.g. "conditions changed at v4"
	savedAt: string;      // ISO instant from the injected clock
	value: T;
};
```

## The defaults

| # | Default | Behavior | Test (name it after its R#) |
|---|---|---|---|
| 1 | Version and input hash | Every write bumps `version` and records `inputHash`. Responses and exports include both. | Two writes produce versions n and n+1, and the hash changes when the input changes. |
| 2 | Atomic write | Write `<file>.tmp-<pid>-<random>`, then `fs.rename` over the target. A throw before the rename leaves the old file untouched. | Make generation or the write throw, then read: the previous version is still served. |
| 3 | Validate before swap | Applying a dataset parses and validates all of it first. Only a fully valid dataset replaces the current one. | Apply an invalid dataset: 400 with the first errors, and the previous dataset is still current. |
| 4 | Base version on every mutation | Generate and apply requests send `baseVersion`. If it differs from the stored version, the server answers 409 with the current version and changes nothing. Mutations in one process run through one promise-chain lock, so two requests never interleave read-modify-write. | Fire two requests with the same `baseVersion`: one succeeds, the other gets 409, and the stored version rose by exactly one. |
| 5 | Stale on input change | Changing conditions or the dataset marks the stored result `stale` with a reason. It does not delete or regenerate the result. The screen shows the stale state. | Change conditions after generating: the result is still there, `status` is `stale`, and `staleReason` names the change. |
| 6 | Export reads the store | Export returns the stored result with `version`, `inputHash`, `status`, and `savedAt`. It never recomputes. | Change conditions, then export: the exported result equals the stored one and says `stale`. |
| 7 | Failure keeps the previous result | A failed generate or apply returns an error body and leaves every stored file as it was. | Same setup as default 2, through the HTTP route. |

## Known limits to record in docs/RISKS.md
- The lock is per process. Two server processes writing the same `var/` can still race. The default stack runs one process.
- `rename` is atomic on one filesystem. A store on a network mount may not be.
- A browser tab holding an old `baseVersion` gets 409 and must reload. Say what the screen shows in that case.
