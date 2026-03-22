---
name: react-best-practices
description: >-
  Applies Vercel Engineering React and Next.js performance guidelines (waterfalls,
  bundle size, RSC/server actions, client fetching, re-renders, rendering, JS
  micro-optimizations). Use when writing, reviewing, or refactoring React/Next.js
  components, hooks, data fetching, Server Actions, route handlers, or performance work;
  or when the user mentions Next.js, RSC, Suspense, bundle size, or waterfalls.
  Do not use for Angular or Go codebases—use those stack-specific skills instead.
license: MIT
metadata:
  source: vercel-react-best-practices
  version: "1.0.0"
---

# React & Next.js Best Practices (Vercel)

Performance-first guidance for React and Next.js. **Full compiled guide:** [react-best-practices.md](react-best-practices.md). **Per-rule sources:** [rules/](rules/) (same layout as the upstream repo’s `rules/`). Repo maintenance notes: [REPO-README.md](REPO-README.md).

## Stack scope

- **Use this skill** for React, React DOM, and Next.js (RSC, Client Components, App Router, etc.).
- **Do not substitute** for Angular (`angular-best-practices` skill / `.ts` + template rules) or Go (`go-best-practices`). If the workspace is Angular or Go–primary, follow those rules; ignore React-only patterns (e.g. Server Actions, RSC props).

## When to apply

- New or refactored components, hooks, routes, Server Actions, API/route handlers
- Data fetching (client or server), caching, serialization across RSC boundaries
- Bundle size, lazy loading, or Core Web Vitals–related work
- Code review focused on performance or common React pitfalls

## Priority order (highest first)

| Tier | Category | Focus |
|------|-----------|--------|
| 1 | Eliminating waterfalls | Parallelize independent async work; defer `await` until needed; Suspense boundaries |
| 2 | Bundle size | Avoid barrel imports; dynamic import heavy UI; defer non-critical third party |
| 3 | Server-side | Auth inside Server Actions; `React.cache()` / LRU where appropriate; minimize RSC props; `after()` for non-blocking work |
| 4 | Client data fetching | SWR dedup; passive listeners; deduped global listeners; versioned minimal `localStorage` |
| 5 | Re-renders | Derive state in render; no inner components; functional `setState`; narrow effect deps; transitions / `useDeferredValue` / refs as appropriate |
| 6 | Rendering | `content-visibility` for long lists; hoist static JSX; hydration/flicker patterns; resource hints |
| 7 | JS hot paths | Maps/Sets, `toSorted`, early exits, hoist RegExp, avoid layout thrashing |
| 8 | Advanced | Init once per app; stable handler patterns (`useEffectEvent` / refs) |

## Rule ID quick reference

Prefixes map to sections in [react-best-practices.md](react-best-practices.md): `async-`, `bundle-`, `server-`, `client-`, `rerender-`, `rendering-`, `js-`, `advanced-`.

Examples: `async-parallel`, `bundle-barrel-imports`, `server-auth-actions`, `rerender-no-inline-components`, `rendering-conditional-render`, `js-tosorted-immutable`.

## How to use this skill

1. For **non-trivial** work, skim the matching section in [react-best-practices.md](react-best-practices.md).
2. For **one rule in depth** (incorrect/correct examples), open the matching file under `rules/<rule-id>.md` (e.g. `/home/mobasir-rc/.gemini/skills/react-best-practices/rules/async-parallel.md`, `rules/bundle-barrel-imports.md`). Filenames use the same prefixes as the quick reference (`async-`, `bundle-`, `server-`, …).
3. Prefer **measurable** improvements: remove sequential awaits where independent, shrink serialized props, split Suspense, direct imports for heavy packages.
4. **Security:** treat Server Actions like public HTTP handlers—always authenticate and authorize inside the action.

## Refreshing from the source repo

After `pnpm build`, the compiled output may still be named `AGENTS.md` upstream. Sync into this skill directory:

```bash
cp <repo>/AGENTS.md /home/mobasir-rc/.gemini/skills/react-best-practices/react-best-practices.md
rsync -a --delete <repo>/rules/ /home/mobasir-rc/.gemini/skills/react-best-practices/rules/
```
