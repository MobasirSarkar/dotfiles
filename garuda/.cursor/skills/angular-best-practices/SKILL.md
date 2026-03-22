---
name: angular-best-practices
description: Expert Angular v20+ code generation, refactoring, and review using PrimeNG and TailwindCSS. Use when writing, reviewing, or debugging Angular components, services, templates, directives, pipes, or routes; or when the user mentions Angular, signals, standalone components, PrimeNG, TailwindCSS, reactive forms, OnPush, inject(), or control flow syntax.
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
```

## 2. Templates — Mandatory Rules

- Use `@if`, `@for`, `@switch` — never `*ngIf`, `*ngFor`, `*ngSwitch`.
- Always provide `track` in `@for`: `@for (item of items(); track item.id)`.
- Use `[class.name]` or `[class]` binding — never `[ngClass]`.
- Use `[style.prop]` or `[style]` binding — never `[ngStyle]`.
- No arrow functions in templates — move logic to the component class.
- No globals in templates (`new Date()`, `Math`, etc.) — expose via a method or signal.
- Use the `async` pipe for observables.

## 3. State Management

- `signal()` for writable local state.
- `computed()` for all derived state — never recalculate in the template.
- `update()` or `set()` to mutate signals — never `mutate()`.
- `effect()` only for genuine side effects (DOM interop, logging) — not for data derivation.

## 4. UI & Styling

- **PrimeNG**: always use PrimeNG components when a native equivalent exists.
- Use `class` attribute (not `styleClass`) on PrimeNG components.
- **TailwindCSS** for all layout, spacing, and typography — no custom SCSS.
- No `::ng-deep` — use PrimeNG PassThrough (`pt`) API for deep customization.
- Only Tailwind palette colors — no arbitrary color values.

## 5. Accessibility

- All components must pass AXE checks and meet WCAG AA minimums.
- Interactive elements need `aria-label` / `aria-labelledby` when text is not visible.
- Manage focus explicitly after dynamic content changes.

## Additional Resources

- [components.md](components.md) — Component anatomy, inputs/outputs, lifecycle, reactive forms, host bindings
- [templates.md](templates.md) — Control flow, class/style bindings, async pipe, accessibility patterns
- [state.md](state.md) — Signals, computed, effects, RxJS interop
- [services.md](services.md) — inject(), providedIn, HTTP patterns, error handling
- [styling.md](styling.md) — PrimeNG usage table, TailwindCSS rules, PassThrough API
