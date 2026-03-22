# Angular Component Patterns

## 1. Component Anatomy

The canonical structure for every Angular v20+ component:

```typescript
import { ChangeDetectionStrategy, Component, computed, inject, input, output } from '@angular/core';

@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserCardComponent {
  // Inputs
  user = input.required<User>();
  size = input<'sm' | 'md' | 'lg'>('md');

  // Outputs
  userSelected = output<User>();

  // Derived state
  fullName = computed(() => `${this.user().firstName} ${this.user().lastName}`);

  // Dependencies
  private userService = inject(UserService);

  // Methods
  select() {
    this.userSelected.emit(this.user());
  }
}
```

**Rules:**
- `selector` follows `kebab-case` with an app prefix: `app-`, `feat-`, etc.
- `templateUrl` and `styleUrl` paths are relative to the TS file.
- Do **NOT** set `standalone: true` — implied by default.
- Do **NOT** set `standalone: false` unless migrating legacy code.

---

## 2. `input()` and `output()` Functions

### Required input

```typescript
// Throws a runtime error if parent does not bind this input
userId = input.required<string>();
```

### Optional input with default

```typescript
disabled = input<boolean>(false);
label = input<string>('Submit');
```

### Aliased input

```typescript
// Parent binds [for-user]="...", component reads this.forUser()
forUser = input<string>('', { alias: 'for-user' });
```

### Output

```typescript
// Typed event emitter
formSubmit = output<FormValue>();
closed = output<void>();

// Emit
this.formSubmit.emit(value);
this.closed.emit();
```

**Never use:**
```typescript
// Bad — old decorator syntax
@Input() userId!: string;
@Output() formSubmit = new EventEmitter<FormValue>();
```

---

## 3. `ChangeDetectionStrategy.OnPush`

OnPush triggers change detection **only when:**
1. An `@Input()` / `input()` reference changes.
2. An event originates from the component or its children.
3. An `async` pipe receives a new emission.
4. A signal read inside the template emits a new value.
5. `markForCheck()` is called explicitly.

**Never causes detection with OnPush:**
- Mutating an object/array that was passed as input (use immutable updates).
- Setting a class property directly without using a signal.

```typescript
// Bad: OnPush will NOT detect this
this.items.push(newItem);

// Good: signal triggers detection
this.items.update(items => [...items, newItem]);
```

---

## 4. Host Bindings

Use the `host` object — never `@HostBinding` or `@HostListener`.

```typescript
@Component({
  selector: 'app-badge',
  template: `<ng-content />`,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'inline-flex items-center rounded-full px-2 py-1',
    '[class.opacity-50]': 'disabled()',
    '[attr.aria-disabled]': 'disabled()',
    '(click)': 'onClick()',
  },
})
export class BadgeComponent {
  disabled = input<boolean>(false);

  onClick() {
    if (!this.disabled()) {
      // handle click
    }
  }
}
```

---

## 5. Lifecycle Hooks & Cleanup

### `DestroyRef` — preferred over `ngOnDestroy`

```typescript
export class SearchComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    const sub = this.searchSvc.results$.subscribe(r => this.results.set(r));
    this.destroyRef.onDestroy(() => sub.unsubscribe());
  }
}
```

### `takeUntilDestroyed()` — cleanest RxJS teardown

```typescript
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

export class SearchComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.searchSvc.results$
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(r => this.results.set(r));
  }
}
```

### Lifecycle order (reference)

`ngOnChanges` → `ngOnInit` → `ngDoCheck` → `ngAfterContentInit` → `ngAfterContentChecked` → `ngAfterViewInit` → `ngAfterViewChecked` → `ngOnDestroy`

Prefer signals + `computed()` over `ngOnChanges` for reacting to input changes.

---

## 6. Reactive Forms

Always prefer Reactive forms over Template-driven forms.

```typescript
import { FormBuilder, Validators } from '@angular/forms';

export class LoginComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  submit() {
    if (this.form.invalid) return;
    const { email, password } = this.form.getRawValue();
    // proceed
  }
}
```

**Template:**

```html
<form [formGroup]="form" (ngSubmit)="submit()">
  <p-floatlabel>
    <inputText id="email" formControlName="email" class="w-full" />
    <label for="email">Email</label>
  </p-floatlabel>

  @if (form.controls.email.invalid && form.controls.email.touched) {
    <p-message severity="error" text="Valid email is required" />
  }

  <p-button type="submit" label="Login" [disabled]="form.invalid" class="w-full mt-4" />
</form>
```

**Rules:**
- Use `getRawValue()` instead of `value` to include disabled controls.
- Use `form.controls.field` over `form.get('field')` — fully typed.
- Expose validation helpers as `computed()` or methods — not inline template expressions.

---

## 7. `NgOptimizedImage`

Use for all static images. Import `NgOptimizedImage` in the component's imports array.

```typescript
import { NgOptimizedImage } from '@angular/common';

@Component({
  imports: [NgOptimizedImage],
  template: `
    <img ngSrc="/assets/logo.png" width="200" height="50" priority alt="Company logo" />
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HeaderComponent {}
```

**Rules:**
- Always provide `width` and `height`.
- Add `priority` for above-the-fold images (LCP candidates).
- Do **not** use `NgOptimizedImage` for inline base64 images.
- Use `fill` mode for images inside a sized container:

```html
<div class="relative w-full h-48">
  <img ngSrc="/assets/hero.jpg" fill alt="Hero image" class="object-cover" />
</div>
```

---

## 8. Smart vs Presentational Components

| Smart (Container) | Presentational |
|---|---|
| Injects services | Receives data via `input()` |
| Manages state signals | Emits events via `output()` |
| Handles routing | No service injection |
| `templateUrl` external | Inline template acceptable |

```typescript
// Smart — fetches and owns data
@Component({ selector: 'app-user-page', ... })
export class UserPageComponent {
  private svc = inject(UserService);
  user = toSignal(this.svc.getUser(this.route.snapshot.params['id']));
}

// Presentational — pure display
@Component({
  selector: 'app-user-avatar',
  template: `<p-avatar [image]="src()" [label]="initials()" shape="circle" />`,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserAvatarComponent {
  src = input<string>('');
  initials = input<string>('');
}
```
