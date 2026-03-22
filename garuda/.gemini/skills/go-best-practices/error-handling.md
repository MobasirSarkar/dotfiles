# Production Error Handling in Go

## 1. Sentinel Errors

Use sentinel errors for well-known, stable conditions that callers need to check programmatically.

```go
// errors.go — defined in the package that owns the domain concept
var (
    ErrNotFound      = errors.New("not found")
    ErrUnauthorized  = errors.New("unauthorized")
    ErrAlreadyExists = errors.New("already exists")
)
```

**Check with `errors.Is`, never `==` on wrapped errors:**

```go
if err := repo.GetUser(ctx, id); err != nil {
    if errors.Is(err, ErrNotFound) {
        return nil, ErrNotFound // re-surface or translate
    }
    return nil, fmt.Errorf("service.GetUser: %w", err)
}
```

---

## 2. Custom Error Types

Use a struct for errors that carry domain-specific fields (HTTP status, operation name, kind/category).

```go
type AppError struct {
    Op      string // operation: "UserService.Create"
    Kind    Kind   // category: KindNotFound, KindUnauthorized, KindInternal
    Message string // human-readable summary
    Err     error  // underlying cause (optional)
}

func (e *AppError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %s: %v", e.Op, e.Message, e.Err)
    }
    return fmt.Sprintf("%s: %s", e.Op, e.Message)
}

func (e *AppError) Unwrap() error { return e.Err }

// Kind categorizes errors for HTTP translation
type Kind uint8

const (
    KindInternal      Kind = iota
    KindNotFound
    KindUnauthorized
    KindValidation
    KindConflict
)
```

**Constructors for common kinds:**

```go
func NotFound(op, msg string) *AppError {
    return &AppError{Op: op, Kind: KindNotFound, Message: msg}
}

func Internal(op string, err error) *AppError {
    return &AppError{Op: op, Kind: KindInternal, Message: "internal error", Err: err}
}
```

**Extract with `errors.As`:**

```go
var appErr *AppError
if errors.As(err, &appErr) {
    switch appErr.Kind {
    case KindNotFound:
        w.WriteHeader(http.StatusNotFound)
    case KindUnauthorized:
        w.WriteHeader(http.StatusUnauthorized)
    default:
        w.WriteHeader(http.StatusInternalServerError)
    }
}
```

---

## 3. Error Wrapping & Context

Wrap at every layer boundary. The format is `"package.Function: %w"`.

```go
// repository layer
func (r *userRepo) Get(ctx context.Context, id string) (*User, error) {
    row := r.db.QueryRowContext(ctx, query, id)
    if err := row.Scan(&u.ID, &u.Name); err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, fmt.Errorf("userRepo.Get %s: %w", id, ErrNotFound)
        }
        return nil, fmt.Errorf("userRepo.Get %s: %w", id, err)
    }
    return &u, nil
}

// service layer
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    u, err := s.repo.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("UserService.GetUser: %w", err)
    }
    return u, nil
}
```

**Rules:**
- One `%w` per `fmt.Errorf` call. Multiple wraps lose unwrapping semantics.
- Never wrap the same error twice at the same level.
- Add the ID / key to the message when it helps diagnosis: `"userRepo.Get id=%s: %w"`.

---

## 4. Logging Policy — Log at the Boundary

Log once, at the outermost entry point (HTTP handler, gRPC handler, job runner). Never log the same error multiple times across layers.

```go
// handler — the boundary
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    u, err := h.svc.GetUser(r.Context(), id)
    if err != nil {
        h.log.ErrorContext(r.Context(), "GetUser failed",
            slog.String("user_id", id),
            slog.Any("error", err),
        )
        writeError(w, err)
        return
    }
    render.JSON(w, r, u)
}
```

Use `log/slog` (stdlib, Go 1.21+) for structured logging. Avoid `fmt.Println` in production paths.

---

## 5. Panic Policy

**Use `panic` only for:**
- Programmer errors detected at startup (bad config, impossible invariant).
- Truly unrecoverable state where continuing would corrupt data.

**Never panic on:**
- User input errors, network failures, or missing database rows.

**Always recover at the top of long-lived goroutines and HTTP servers:**

```go
func safeGo(log *slog.Logger, fn func()) {
    go func() {
        defer func() {
            if r := recover(); r != nil {
                log.Error("goroutine panicked", slog.Any("panic", r),
                    slog.String("stack", string(debug.Stack())))
            }
        }()
        fn()
    }()
}
```

**HTTP middleware recover:**

```go
func RecoverMiddleware(log *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            defer func() {
                if rec := recover(); rec != nil {
                    log.ErrorContext(r.Context(), "http handler panic",
                        slog.Any("panic", rec),
                        slog.String("stack", string(debug.Stack())),
                    )
                    http.Error(w, "internal server error", http.StatusInternalServerError)
                }
            }()
            next.ServeHTTP(w, r)
        })
    }
}
```

---

## 6. Multi-Error Aggregation with `errgroup`

Use `golang.org/x/sync/errgroup` when launching concurrent work that can each return an error.

```go
import "golang.org/x/sync/errgroup"

func (s *Service) FetchAll(ctx context.Context, ids []string) ([]*User, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([]*User, len(ids))

    for i, id := range ids {
        i, id := i, id // capture loop vars
        g.Go(func() error {
            u, err := s.repo.Get(ctx, id)
            if err != nil {
                return fmt.Errorf("FetchAll id=%s: %w", id, err)
            }
            results[i] = u
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, fmt.Errorf("Service.FetchAll: %w", err)
    }
    return results, nil
}
```

**`errgroup` rules:**
- `errgroup.WithContext` cancels the ctx on first error — all other goroutines must respect it.
- Only the first non-nil error is returned. Design accordingly or use a multi-error collector.
- Pre-allocate result slice by index to avoid mutex contention.

---

## 7. Multi-Error Collector (when all errors matter)

```go
type MultiError []error

func (m MultiError) Error() string {
    msgs := make([]string, len(m))
    for i, e := range m {
        msgs[i] = e.Error()
    }
    return strings.Join(msgs, "; ")
}

func (m MultiError) Unwrap() []error { return []error(m) }
```

Use when you need to collect all validation errors before returning:

```go
func validate(req Request) error {
    var errs MultiError
    if req.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if req.Age < 0 {
        errs = append(errs, errors.New("age must be non-negative"))
    }
    if len(errs) > 0 {
        return errs
    }
    return nil
}
```

---

## 8. HTTP Error Translation

Centralize error-to-status-code mapping in one place:

```go
func writeError(w http.ResponseWriter, err error) {
    var appErr *AppError
    if errors.As(err, &appErr) {
        code := kindToStatus(appErr.Kind)
        http.Error(w, appErr.Message, code)
        return
    }
    http.Error(w, "internal server error", http.StatusInternalServerError)
}

func kindToStatus(k Kind) int {
    switch k {
    case KindNotFound:     return http.StatusNotFound
    case KindUnauthorized: return http.StatusUnauthorized
    case KindValidation:   return http.StatusBadRequest
    case KindConflict:     return http.StatusConflict
    default:               return http.StatusInternalServerError
    }
}
```
