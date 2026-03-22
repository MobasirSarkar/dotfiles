# State Management with Angular Signals

## 1. `signal()` — Writable Local State

Use `signal()` for any component state that changes over time.

```typescript
export class CartComponent {
  items = signal<CartItem[]>([]);
  loading = signal(false);
  error = signal<string | null>(null);

  addItem(item: CartItem) {
    this.items.update(items => [...items, item]);
  }

  removeItem(id: string) {
    this.items.update(items => items.filter(i => i.id !== id));
  }

  clearCart() {
    this.items.set([]);
  }
}
```

**Rules:**
- Use `set()` to replace the entire value.
- Use `update(prev => ...)` when the new value depends on the previous value.
- Never use `mutate()` — it is removed in Angular v17+.
- Never mutate the signal's value by reference (e.g., `this.items().push(...)`) — always return a new reference.

```typescript
// Bad — mutates the array in place; OnPush won't detect it
this.items().push(newItem);

// Good — returns a new array
this.items.update(items => [...items, newItem]);
```

---

## 2. `computed()` — Derived State

Use `computed()` for any value that depends on one or more signals. It is memoized — recalculates only when its dependencies change.

```typescript
export class OrderSummaryComponent {
  items = signal<OrderItem[]>([]);
  discount = signal(0);

  subtotal = computed(() => this.items().reduce((sum, i) => sum + i.price * i.qty, 0));
  discountAmount = computed(() => this.subtotal() * (this.discount() / 100));
  total = computed(() => this.subtotal() - this.discountAmount());
  itemCount = computed(() => this.items().reduce((n, i) => n + i.qty, 0));
  isEmpty = computed(() => this.items().length === 0);
}
```

**Rules:**
- `computed()` is read-only — you cannot `.set()` it.
- Never duplicate derived values in multiple `computed()` calls — compose them.
- Never call a method with side effects inside `computed()` — it must be a pure function.
- Prefer `computed()` over methods for values used in templates — methods run on every CD cycle; `computed()` is cached.

```html
<!-- Bad: recalculates every change detection cycle -->
<span>{{ calculateTotal() }}</span>

<!-- Good: cached -->
<span>{{ total() }}</span>
```

---

## 3. `effect()` — Side Effects

Use `effect()` only for genuine side effects: DOM interaction, logging, external system sync, localStorage writes. **Do not use for data derivation** — use `computed()` for that.

```typescript
export class ThemeComponent {
  theme = signal<'light' | 'dark'>('light');

  constructor() {
    effect(() => {
      document.documentElement.classList.toggle('dark', this.theme() === 'dark');
      localStorage.setItem('theme', this.theme());
    });
  }
}
```

**Rules:**
- `effect()` must be called in a reactive context (constructor, field initializer, or inside `runInInjectionContext`).
- Use `{ allowSignalWrites: true }` only when absolutely necessary — it can cause infinite loops.
- Prefer `toObservable()` + RxJS operators over `effect()` for complex async reactions.
- Clean up subscriptions inside `effect()` using the `onCleanup` callback:

```typescript
effect(onCleanup => {
  const timer = setInterval(() => this.tick.update(n => n + 1), 1000);
  onCleanup(() => clearInterval(timer));
});
```

---

## 4. Signal Inputs — Reactive to Parent Changes

`input()` signals are read-only and automatically reactive. Combine with `computed()` to react to input changes without `ngOnChanges`.

```typescript
export class PaginatorComponent {
  items = input.required<unknown[]>();
  pageSize = input<number>(10);
  currentPage = signal(1);

  // Reacts automatically when items() or pageSize() changes
  totalPages = computed(() => Math.ceil(this.items().length / this.pageSize()));
  pagedItems = computed(() => {
    const start = (this.currentPage() - 1) * this.pageSize();
    return this.items().slice(start, start + this.pageSize());
  });

  goToPage(page: number) {
    this.currentPage.set(Math.max(1, Math.min(page, this.totalPages())));
  }
}
```

---

## 5. `linkedSignal()` — Writable Computed Signal (v19+)

Use `linkedSignal()` when you need a writable signal that resets when a source signal changes.

```typescript
export class TabsComponent {
  tabs = input.required<Tab[]>();

  // Resets to the first tab whenever the tabs input changes
  activeTab = linkedSignal(() => this.tabs()[0]);

  selectTab(tab: Tab) {
    this.activeTab.set(tab);
  }
}
```

---

## 6. `resource()` — Async Data Loading (v19+)

Use `resource()` for loading async data that reacts to signal changes. Replaces manual loading/error/data signal trios.

```typescript
import { resource } from '@angular/core';

export class UserDetailComponent {
  userId = input.required<string>();

  userResource = resource({
    request: () => ({ id: this.userId() }),
    loader: ({ request, abortSignal }) =>
      fetch(`/api/users/${request.id}`, { signal: abortSignal })
        .then(r => r.json() as Promise<User>),
  });

  // Use in template:
  // userResource.value()  — the data
  // userResource.isLoading() — loading state
  // userResource.error()  — error state
}
```

Template usage:

```html
@if (userResource.isLoading()) {
  <p-skeleton height="200px" />
} @else if (userResource.error()) {
  <p-message severity="error" [text]="userResource.error()?.message" />
} @else if (userResource.value(); as user) {
  <app-user-card [user]="user" />
}
```

---

## 7. RxJS Interop — `toSignal()` and `toObservable()`

### `toSignal()` — Convert Observable to Signal

```typescript
import { toSignal } from '@angular/core/rxjs-interop';

export class SearchComponent {
  private svc = inject(SearchService);

  query = signal('');

  // Convert query signal to observable for debouncing
  results = toSignal(
    toObservable(this.query).pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(q => this.svc.search(q)),
    ),
    { initialValue: [] },
  );
}
```

**`toSignal()` options:**

| Option | Use |
|---|---|
| `initialValue` | Provide a value before the observable emits |
| `requireSync` | Asserts the observable emits synchronously (BehaviorSubject) |
| `injector` | Pass when calling outside of injection context |

### `toObservable()` — Convert Signal to Observable

```typescript
import { toObservable } from '@angular/core/rxjs-interop';

export class FilterComponent {
  activeFilter = signal('all');

  // Chain RxJS operators on a signal
  filtered$ = toObservable(this.activeFilter).pipe(
    switchMap(filter => this.dataService.getFiltered(filter)),
  );
}
```

---

## 8. Service-Level State with Signals

For shared state across components, expose signals from a service:

```typescript
@Injectable({ providedIn: 'root' })
export class AuthStore {
  private _user = signal<User | null>(null);
  private _token = signal<string | null>(null);

  // Public read-only views
  readonly user = this._user.asReadonly();
  readonly token = this._token.asReadonly();
  readonly isAuthenticated = computed(() => this._user() !== null);
  readonly displayName = computed(() => this._user()?.name ?? 'Guest');

  setUser(user: User, token: string) {
    this._user.set(user);
    this._token.set(token);
  }

  logout() {
    this._user.set(null);
    this._token.set(null);
  }
}
```

**Rules:**
- Expose private signals as `.asReadonly()` to prevent external mutation.
- All mutations go through service methods — never expose the writable signal publicly.
- Use `computed()` for all derived views — never re-derive in components.

---

## 9. Form State Integration

Bridge reactive forms and signals when you need to react to form value changes:

```typescript
export class FilterFormComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    search: [''],
    status: ['all'],
    dateRange: [null as DateRange | null],
  });

  // Convert form valueChanges observable to a signal
  filters = toSignal(
    this.form.valueChanges.pipe(debounceTime(200), distinctUntilChanged()),
    { initialValue: this.form.getRawValue() },
  );

  // Derive filtered results reactively
  results = toSignal(
    toObservable(this.filters).pipe(
      switchMap(f => this.dataService.query(f)),
    ),
    { initialValue: [] },
  );
}
```
