# Angular Template Patterns

## 1. Native Control Flow — Mandatory

Use `@if`, `@for`, `@switch`. Never use `*ngIf`, `*ngFor`, or `*ngSwitch`.

### `@if` / `@else if` / `@else`

```html
@if (user()) {
  <app-user-card [user]="user()!" />
} @else if (loading()) {
  <p-skeleton height="4rem" class="w-full" />
} @else {
  <p-message severity="warn" text="No user found." />
}
```

### `@for` with mandatory `track`

```html
@for (item of items(); track item.id) {
  <app-list-item [item]="item" (remove)="onRemove(item.id)" />
} @empty {
  <p class="text-slate-500 text-sm">No items yet.</p>
}
```

**Rules:**
- `track` is required — always track by a stable unique identifier (`item.id`, `item.uuid`).
- Use `@empty` to handle empty lists gracefully instead of a separate `@if`.
- Expose the index with `let i = $index` when needed: `@for (item of items(); track item.id; let i = $index)`.

### `@switch`

```html
@switch (status()) {
  @case ('active') { <p-tag severity="success" value="Active" /> }
  @case ('pending') { <p-tag severity="warning" value="Pending" /> }
  @case ('inactive') { <p-tag severity="danger" value="Inactive" /> }
  @default { <p-tag value="Unknown" /> }
}
```

---

## 2. Class Bindings — No `ngClass`

```html
<!-- Single conditional class -->
<div [class.is-active]="item.active"></div>

<!-- Object map -->
<div [class]="{ 'border-primary-500': selected(), 'opacity-50': disabled() }"></div>

<!-- Computed class string from component -->
<div [class]="cardClasses()"></div>
```

In the component:

```typescript
cardClasses = computed(() => ({
  'border-2 border-primary-500': this.selected(),
  'opacity-50 pointer-events-none': this.disabled(),
  'shadow-lg': this.elevated(),
}));
```

**Never:**
```html
<!-- Bad -->
<div [ngClass]="{ active: isActive }"></div>
```

---

## 3. Style Bindings — No `ngStyle`

```html
<!-- Single property -->
<div [style.width.px]="width()"></div>
<div [style.background-color]="brandColor()"></div>

<!-- Object map -->
<div [style]="{ height: rowHeight() + 'px', opacity: alpha() }"></div>
```

**Never:**
```html
<!-- Bad -->
<div [ngStyle]="{ 'font-size': fontSize + 'px' }"></div>
```

---

## 4. No Arrow Functions in Templates

Arrow functions are not supported in Angular templates. Move all logic to the component class.

```html
<!-- Bad: arrow function in template -->
<p-button (onClick)="items.update(i => i.filter(x => x.id !== item.id))" />

<!-- Good: delegate to a method -->
<p-button (onClick)="removeItem(item.id)" />
```

```typescript
removeItem(id: string) {
  this.items.update(items => items.filter(x => x.id !== id));
}
```

---

## 5. No Globals in Templates

Never use `new Date()`, `Math`, `JSON`, `Object` or other globals in the template. Expose them through the component.

```html
<!-- Bad -->
<span>{{ new Date() | date:'short' }}</span>

<!-- Good -->
<span>{{ today() | date:'short' }}</span>
```

```typescript
today = signal(new Date());
```

---

## 6. Async Pipe for Observables

Use `async` pipe to subscribe and unsubscribe automatically. Combine with a wrapping `@if` to handle null-safety.

```html
@if (user$ | async; as user) {
  <app-user-card [user]="user" />
}
```

For multiple observables, prefer `toSignal()` in the component to avoid nested async pipes:

```typescript
user = toSignal(this.userService.user$, { initialValue: null });
```

Then in the template:

```html
@if (user()) {
  <app-user-card [user]="user()!" />
}
```

---

## 7. Two-Way Binding

Use `[(ngModel)]` only for simple inputs in template-driven forms. For reactive forms use `formControlName`.

For signal-based two-way binding in custom components, use the linked signal pattern:

```typescript
// Parent passes a signal value; child emits updates
value = input<string>('');
valueChange = output<string>();
```

```html
<!-- Parent -->
<app-text-input [(value)]="mySignal" />
```

---

## 8. Pipes — Performance Rules

- Prefer pure pipes — they are cached by Angular's change detection.
- Never call functions in templates that are not memoized — use `computed()` instead.

```html
<!-- Bad: called on every CD cycle -->
<span>{{ formatCurrency(amount()) }}</span>

<!-- Good: computed or a pure pipe -->
<span>{{ formattedAmount() }}</span>
<span>{{ amount() | currency:'USD' }}</span>
```

---

## 9. Template Variables with `@let`

Angular v18+ supports `@let` for local template variables:

```html
@let total = cartItems().reduce(sumFn, 0);
<p>Total: {{ total | currency }}</p>
```

Use `@let` for intermediate computed values inside templates to avoid repeating the same expression.

---

## 10. Accessibility (WCAG AA / AXE)

### ARIA labels on icon-only buttons

```html
<p-button icon="pi pi-trash" [rounded]="true" severity="danger"
  aria-label="Delete item" />
```

### Form field association

```html
<label for="email" class="block text-sm font-medium mb-1">Email</label>
<inputText id="email" formControlName="email" class="w-full"
  aria-required="true" [attr.aria-invalid]="form.controls.email.invalid && form.controls.email.touched" />
```

### Role and live regions for dynamic content

```html
<div role="status" aria-live="polite" aria-atomic="true">
  @if (saveSuccess()) {
    <span class="sr-only">Changes saved successfully.</span>
  }
</div>
```

### Focus management after navigation

```typescript
export class ModalComponent {
  private el = inject(ElementRef);

  ngAfterViewInit() {
    (this.el.nativeElement.querySelector('[autofocus]') as HTMLElement)?.focus();
  }
}
```

### Keyboard navigation in custom components

- All interactive elements must be reachable via `Tab`.
- `Enter` and `Space` must trigger the primary action on custom buttons.
- Use `tabindex="0"` on non-native interactive elements and `tabindex="-1"` to remove from tab order.

### Color contrast

- Text on backgrounds must meet 4.5:1 ratio (WCAG AA normal text).
- Large text (18pt / 14pt bold) requires 3:1.
- Use only Tailwind palette colors — they are calibrated. Avoid low-contrast combos like `text-gray-400` on `bg-white`.

---

## 11. Template Organization

Keep templates readable by extracting sub-templates into child components rather than deeply nesting:

```html
<!-- Bad: deep nesting, hard to read -->
<div class="p-4">
  <div class="flex items-center gap-3">
    <div class="rounded-full ...">
      <img ... />
      <div>
        <span>{{ user().name }}</span>
        ...
      </div>
    </div>
  </div>
</div>

<!-- Good: extract to a component -->
<app-user-avatar [user]="user()" />
```

- External `templateUrl` for components with more than ~20 lines of HTML.
- Inline `template` for simple, small components (< 10 lines).
