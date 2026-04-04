# Angular Services & Dependency Injection

## 1. Service Anatomy

```typescript
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map, throwError } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);
  private config = inject(AppConfig);

  getUser(id: string): Observable<User> {
    return this.http.get<UserDto>(`${this.config.apiUrl}/users/${id}`).pipe(
      map(dto => mapUserDto(dto)),
      catchError(err => throwError(() => mapHttpError(err))),
    );
  }
}
```

**Rules:**
- Always `providedIn: 'root'` for application-wide singletons.
- Use `inject()` at the field declaration level — never constructor injection.
- Design each service around a **single responsibility**.
- Never store mutable component-local state in a service.

---

## 2. `inject()` — Dependency Injection

Prefer `inject()` over constructor injection in all contexts.

```typescript
// Bad — constructor injection
@Injectable({ providedIn: 'root' })
export class OrderService {
  constructor(private http: HttpClient, private auth: AuthStore) {}
}

// Good — inject()
@Injectable({ providedIn: 'root' })
export class OrderService {
  private http = inject(HttpClient);
  private auth = inject(AuthStore);
}
```

**Injection contexts:**
- Field initializers in classes are injection contexts.
- `inject()` can also be called inside factory functions passed to `provide*` helpers.
- Outside of a class, wrap with `runInInjectionContext(injector, fn)`.

```typescript
// Feature-level provider scope
export const userRoutes: Routes = [
  {
    path: 'users',
    providers: [UserService],   // scoped to this route subtree
    loadComponent: () => import('./user-list.component'),
  },
];
```

---

## 3. Service Scoping

| Scope | How | When |
|---|---|---|
| Application singleton | `providedIn: 'root'` | Shared global state, HTTP services |
| Feature/module scope | `providers: [MyService]` in route config | Feature-isolated state |
| Component scope | `providers: [MyService]` in `@Component` | Instance-per-component |

```typescript
// Component-scoped: a new instance per component
@Component({
  providers: [FormStateService],
  ...
})
export class CheckoutComponent {
  private formState = inject(FormStateService);
}
```

---

## 4. HTTP Patterns with `HttpClient`

### Basic request with typed response

```typescript
getUsers(filter: UserFilter): Observable<PaginatedResult<User>> {
  const params = new HttpParams({ fromObject: { ...filter } });
  return this.http.get<PaginatedResultDto<UserDto>>('/api/users', { params }).pipe(
    map(dto => mapPaginatedResult(dto, mapUserDto)),
    catchError(err => throwError(() => mapHttpError(err))),
  );
}
```

### `toSignal()` for component consumption

```typescript
// In component — auto-subscribes, cleans up on destroy
export class UserListComponent {
  private svc = inject(UserService);

  users = toSignal(this.svc.getUsers({}), { initialValue: [] });
}
```

### Resource-based loading (v19+)

```typescript
export class UserDetailComponent {
  private svc = inject(UserService);
  userId = input.required<string>();

  userResource = resource({
    request: () => this.userId(),
    loader: ({ request }) => firstValueFrom(this.svc.getUser(request)),
  });
}
```

### Interceptors (functional style — Angular v15+)

```typescript
// auth.interceptor.ts
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthStore);
  const token = auth.token();

  if (!token) return next(req);

  return next(req.clone({
    setHeaders: { Authorization: `Bearer ${token}` },
  }));
};

// app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(withInterceptors([authInterceptor])),
  ],
};
```

### Error interceptor

```typescript
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status === 401) {
        router.navigate(['/login']);
      }
      return throwError(() => mapHttpError(err));
    }),
  );
};
```

---

## 5. Error Handling in Services

### Typed error model

```typescript
export interface ApiError {
  code: string;
  message: string;
  status: number;
  details?: Record<string, string[]>;
}

function mapHttpError(err: HttpErrorResponse): ApiError {
  return {
    code: err.error?.code ?? 'UNKNOWN',
    message: err.error?.message ?? err.message,
    status: err.status,
    details: err.error?.details,
  };
}
```

### Service-level error handling

```typescript
createUser(dto: CreateUserDto): Observable<User> {
  return this.http.post<UserDto>('/api/users', dto).pipe(
    map(mapUserDto),
    catchError((err: HttpErrorResponse) => {
      if (err.status === 409) {
        return throwError(() => ({ ...mapHttpError(err), code: 'USER_EXISTS' }));
      }
      return throwError(() => mapHttpError(err));
    }),
  );
}
```

### Component-level error state

```typescript
export class CreateUserComponent {
  private svc = inject(UserService);

  loading = signal(false);
  error = signal<ApiError | null>(null);

  submit(dto: CreateUserDto) {
    this.loading.set(true);
    this.error.set(null);

    this.svc.createUser(dto)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: user => this.router.navigate(['/users', user.id]),
        error: (err: ApiError) => this.error.set(err),
      });
  }
}
```

---

## 6. The `AppConfig` / Environment Pattern

Inject configuration via Angular's injection system — never call `environment` directly in services.

```typescript
// app.config.ts
export interface AppConfig {
  apiUrl: string;
  featureFlags: FeatureFlags;
}

export const APP_CONFIG = new InjectionToken<AppConfig>('APP_CONFIG');

export const appConfig: ApplicationConfig = {
  providers: [
    { provide: APP_CONFIG, useValue: { apiUrl: environment.apiUrl, featureFlags: environment.featureFlags } },
  ],
};
```

```typescript
@Injectable({ providedIn: 'root' })
export class ApiService {
  private config = inject(APP_CONFIG);

  private baseUrl = this.config.apiUrl;
}
```

---

## 7. Store Services — Shared Signal State

When a service needs to share state across components, use signals with read-only public views:

```typescript
@Injectable({ providedIn: 'root' })
export class NotificationStore {
  private _notifications = signal<Notification[]>([]);

  readonly notifications = this._notifications.asReadonly();
  readonly unreadCount = computed(() => this._notifications().filter(n => !n.read).length);
  readonly hasUnread = computed(() => this.unreadCount() > 0);

  add(notification: Omit<Notification, 'id' | 'read'>) {
    const n: Notification = { ...notification, id: crypto.randomUUID(), read: false };
    this._notifications.update(list => [n, ...list]);
  }

  markRead(id: string) {
    this._notifications.update(list =>
      list.map(n => n.id === id ? { ...n, read: true } : n),
    );
  }

  dismiss(id: string) {
    this._notifications.update(list => list.filter(n => n.id !== id));
  }
}
```

---

## 8. Single Responsibility Checklist

Before creating or expanding a service, verify:

- [ ] The service has one clearly named domain concern (`UserService`, `CartService`, `AuthStore`).
- [ ] It does not reach into another domain's HTTP endpoints.
- [ ] It does not orchestrate multiple unrelated operations.
- [ ] State it holds is truly shared — not local to one component.
- [ ] HTTP methods map to one resource type (not mixed `/users` and `/orders` calls).

If a service is doing too much, split it: e.g., `UserService` (HTTP) + `UserStore` (state).
