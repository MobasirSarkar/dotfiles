---
description: 
globs: "**/*.ts, **/*.html"
alwaysApply: false
---

# Angular v20+ Best Practices

You are an expert Angular developer. Apply every rule below unconditionally for all code generation, refactoring, and review. The stack is **Angular v20+**, **PrimeNG (latest)**, and **TailwindCSS**.

## 1. Component Fundamentals

- Do **NOT** set `standalone: true` — it is the default in v20+.
- Always set `changeDetection: ChangeDetectionStrategy.OnPush`.
- Use `input()` / `output()` functions — never `@Input()` / `@Output()` decorators.
- Use `inject()` at field declaration level — never constructor injection.
- Place host bindings in the `host: {}` object of `@Component` or `@Directive` — never `@HostBinding` / `@HostListener`.
- Use paths relative to the TS file for `templateUrl` and `styleUrl`.

```typescript
// ✅ Good
@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'block' },
})
export class UserCardComponent {
  user = input.required<User>();
  selected = output<User>();
  private svc = inject(UserService);
}

// ❌ Bad
@Component({ standalone: true, ... })
export class UserCardComponent {
  @Input() user!: User;
  @Output() selected = new EventEmitter<User>();
  constructor(private svc: UserService) {}
}
```

## 2. Templates — Mandatory Rules

- Use `@if`, `@for`, `@switch` — never `*ngIf`, `*ngFor`, `*ngSwitch`.
- Always provide `track` in `@for`: `@for (item of items(); track item.id)`.
- Use `[class.name]` or `[class]` binding — never `[ngClass]`.
- Use `[style.prop]` or `[style]` binding — never `[ngStyle]`.
- No arrow functions in templates — move logic to the component class.
- No globals in templates (`new Date()`, `Math`, etc.) — expose via a method or signal.
- Use the `async` pipe for observables.

```html
<!-- ✅ Good -->
@if (user()) {
  <p-card [class]="isActive() ? 'border-primary' : ''">
    @for (item of items(); track item.id) {
      <li>{{ item.name }}</li>
    }
  </p-card>
}

<!-- ❌ Bad -->
<p-card *ngIf="user" [ngClass]="{ 'border-primary': isActive }">
  <li *ngFor="let item of items">{{ item.name }}</li>
</p-card>
```

## 3. State Management

- `signal()` for writable local state.
- `computed()` for all derived state — never recalculate in the template.
- `update()` or `set()` to mutate signals — never `mutate()`.
- `effect()` only for genuine side effects (DOM interop, logging) — not for data derivation.

```typescript
// ✅ Good
count = signal(0);
doubled = computed(() => this.count() * 2);

increment() {
  this.count.update(v => v + 1);
}

// ❌ Bad — derived state in template
// <span>{{ count() * 2 }}</span>

// ❌ Bad — effect for derivation
effect(() => { this.doubled.set(this.count() * 2); });
```

## 4. UI & Styling

- **PrimeNG**: always use PrimeNG components when a native equivalent exists.
- Use `class` attribute (not `styleClass`) on PrimeNG components.
- **TailwindCSS** for all layout, spacing, and typography — no custom SCSS.
- No `::ng-deep` — use PrimeNG PassThrough (`pt`) API for deep customization.
- Only Tailwind palette colors — no arbitrary color values.

```html
<!-- ✅ Good -->
<p-button
  label="Save"
  class="w-full"
  [pt]="{ root: { class: 'rounded-lg' } }"
/>

<!-- ❌ Bad -->
<p-button styleClass="my-btn" />
<style> ::ng-deep .my-btn { border-radius: 8px; } </style>
```

## 5. Accessibility

- All components must pass AXE checks and meet WCAG AA minimums.
- Interactive elements need `aria-label` / `aria-labelledby` when text is not visible.
- Manage focus explicitly after dynamic content changes.

```html
<!-- ✅ Good -->
<p-button icon="pi pi-close" aria-label="Close dialog" (click)="close()" />

<div role="status" aria-live="polite">
  @if (saved()) { <span>Changes saved</span> }
</div>
```

---

description:
globs: **/*.go
alwaysApply: false
---

# Go Best Practices

You are an expert Go maintainer. Apply every rule below unconditionally for all code generation, refactoring, and review.

## 1. Package & Naming

- Package names: short, lowercase, single-word (`user`, `store`, `transport`). Never `user_service` or `UserHelpers`.
- Export (`UpperCamelCase`) only what is part of the public contract. Keep the API surface minimal.
- Use `mixedCaps` / `MixedCaps` — never underscores in identifiers.
- Acronyms are all-caps: `userID`, `APIClient`, `serveHTTP`, `parseURL`.
- Short names for short-lived vars: `i` (index), `r` (reader), `w` (writer), `buf` (buffer).
- Receiver names: short, consistent, never `this`/`self`. Use first letter of type: `u *User`.

## 2. Functions & Guard Clauses

- Error is always the last return value: `func Do(ctx context.Context) (Result, error)`.
- Return early on errors. Never use `else` after `return`:

```go
// ❌ Bad
if err == nil {
    doWork()
} else {
    return err
}

// ✅ Good
if err != nil {
    return fmt.Errorf("doing work: %w", err)
}
doWork()
```

- Keep the happy path left-aligned. Every early return reduces nesting.
- Functions should do one thing. If you need a comment to explain a block, extract a function.

## 3. Error Handling

- Never discard errors with `_` unless the function is provably infallible.
- Wrap with context at every layer boundary: `fmt.Errorf("repo.GetUser: %w", err)`.
- Check with `errors.Is` / `errors.As`, never string comparison.
- Log errors at the boundary (handler/service entry point) — not deep in the stack.

```go
// ❌ Bad
if err.Error() == "not found" { ... }

// ✅ Good
if errors.Is(err, ErrNotFound) { ... }

var ve *ValidationError
if errors.As(err, &ve) { ... }
```

## 4. Concurrency

- `context.Context` is always the first argument: `func (s *Service) Fetch(ctx context.Context, id string)`.
- Every goroutine must have a defined termination strategy.
- Prefer `errgroup.WithContext` over raw `sync.WaitGroup`.
- Use channels for data flow; mutexes for protecting state.

```go
// ✅ Good: errgroup for parallel work with cancellation
g, ctx := errgroup.WithContext(ctx)
g.Go(func() error { return fetchA(ctx) })
g.Go(func() error { return fetchB(ctx) })
if err := g.Wait(); err != nil {
    return fmt.Errorf("parallel fetch: %w", err)
}
```

## 5. Pointers vs. Values

- If any method on a type has a pointer receiver, all methods must use pointer receivers.
- Never pass `*[]T`, `*map[K]V`, or `*chan T` — they are already reference types.
- Pass large structs by pointer (`*T`); pass small structs and scalars by value.
- Always nil-check pointers returned from functions unless the API contract guarantees non-nil.

## 6. Slices & Maps

- Pre-allocate when capacity is known: `make([]T, 0, n)`.
- Pre-size maps: `make(map[K]V, n)`.
- Never append in a loop without pre-allocation when the final length is known.
- Use `copy` instead of a loop for slice duplication.

```go
// ❌ Bad
var results []Result
for _, item := range items {
    results = append(results, process(item))
}

// ✅ Good
results := make([]Result, 0, len(items))
for _, item := range items {
    results = append(results, process(item))
}
```

## 7. Interfaces

- Prefer 1–3 method interfaces (`io.Reader`, `io.Writer`).
- Define interfaces where they are *consumed*, not where implementations live.
- Don't create interfaces speculatively. Add one only when you have ≥2 concrete implementations or need to mock for testing.

```go
// ✅ Good: defined at the consumer
// in package handler
type UserStore interface {
    GetUser(ctx context.Context, id string) (*User, error)
}
```

## 8. Testing

- All tests are table-driven with `t.Run`.
- Use `t.Parallel()` for independent unit tests.
- Use `require` (fatal) for setup/preconditions; `assert` (non-fatal) for assertions.
- Use `//go:build integration` tag to separate slow integration tests.

```go
func TestGetUser(t *testing.T) {
    t.Parallel()
    tests := []struct {
        name    string
        id      string
        want    *User
        wantErr bool
    }{
        {name: "found", id: "1", want: &User{ID: "1"}},
        {name: "not found", id: "999", wantErr: true},
    }
    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            got, err := store.GetUser(context.Background(), tc.id)
            if tc.wantErr {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            assert.Equal(t, tc.want, got)
        })
    }
}

---
description: React/Next.js performance via global react-best-practices skill; JSX/Next globs only; defers to Angular/Go elsewhere.
globs: "**/*.{tsx,jsx}, **/middleware.{ts,js}, **/next.config.{js,mjs,mts,ts}, **/app/**/route.{ts,js}, **/src/app/**/route.{ts,js}"
alwaysApply: false
---

# React best practices (skill-backed)

Applies only when the **matched files** are part of a React or Next.js stack. This rule must **not** override **angular-best-practices** or **go-best-practices**.

## Coexistence with other user rules

- **Angular** (`.ts` components, `.html`, `@angular/*`): follow `angular-best-practices` and the Angular skill. **Ignore** this React rule’s workflow for those files—even if a file is `.ts`, if it is Angular (e.g. `*.component.ts`, `angular.json`, `@angular/core` imports), do not apply React/Next or RSC guidance here.
- **Go** (`*.go`): follow `go-best-practices` only.
- **Both rules in play** (monorepo): apply the rule that matches the **file you are editing** and the **imports/framework** in that file; do not merge conflicting patterns.

## When this rule applies

If the open task clearly concerns React/Next (matched globs or user intent), then:

1. Use the **`react-best-practices`** skill.
2. Read the skill's `react-best-practices.md` as needed for the topic.
3. For a **single rule** with full bad/good examples, read the skill's `rules/<rule-id>.md` (e.g. `async-parallel.md`, `server-auth-actions.md`).
4. Implement accordingly unless the user overrides.

## Non-negotiables (React/Next only)

- Remove avoidable async waterfalls; parallelize independent work.
- Avoid barrel imports for heavy packages; lazy-load large client-only UI when appropriate.
- Authenticate and authorize **inside** every Server Action; validate inputs.
- Minimize props serialized to client components; avoid redundant derived arrays/objects at the RSC boundary.
- No components defined inside other components; derive state in render; functional `setState` when based on prior state.
```
