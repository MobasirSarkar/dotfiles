# Go Design Patterns & Project Layout

## 1. Functional Options Pattern

Use functional options when constructors have more than 3 optional parameters.

```go
type Server struct {
    addr        string
    timeout     time.Duration
    maxConns    int
    logger      *slog.Logger
    middlewares []Middleware
}

type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) { s.timeout = d }
}

func WithMaxConns(n int) Option {
    return func(s *Server) { s.maxConns = n }
}

func WithLogger(l *slog.Logger) Option {
    return func(s *Server) { s.logger = l }
}

func WithMiddleware(m ...Middleware) Option {
    return func(s *Server) { s.middlewares = append(s.middlewares, m...) }
}

func NewServer(addr string, opts ...Option) *Server {
    s := &Server{
        addr:     addr,
        timeout:  30 * time.Second, // sensible defaults
        maxConns: 100,
        logger:   slog.Default(),
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

**Usage:**

```go
srv := NewServer(":8080",
    WithTimeout(10*time.Second),
    WithMaxConns(500),
    WithLogger(logger),
)
```

**When to use:** constructors with optional config, SDK clients, middleware chains.
**When not to use:** simple structs with 1–2 fields — just use a plain struct literal.

---

## 2. Repository Pattern

The interface lives at the **consumer** (service layer), not at the implementation (store layer).

```go
// internal/service/user.go — consumer defines the interface
type UserRepository interface {
    Get(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter UserFilter) ([]*User, int, error)
}

type UserService struct {
    repo   UserRepository
    events EventPublisher
    log    *slog.Logger
}

func NewUserService(repo UserRepository, events EventPublisher, log *slog.Logger) *UserService {
    return &UserService{repo: repo, events: events, log: log}
}
```

```go
// internal/store/postgres/user.go — implementation, no interface here
type userRepo struct {
    db *sql.DB
}

func NewUserRepo(db *sql.DB) *userRepo {
    return &userRepo{db: db}
}

func (r *userRepo) Get(ctx context.Context, id string) (*User, error) {
    // ...
}
```

**Rules:**
- The store package exports the concrete type; the service package owns the interface.
- The interface should be as narrow as the service actually needs.
- Never define `UserRepositoryInterface` in the store package — that is the implementation leaking its contract.

---

## 3. Dependency Injection — Constructor Args Only

Pass all dependencies as constructor arguments. Never use `init()` for side-effectful setup or global singletons.

```go
// Bad: global state, untestable
var db *sql.DB

func init() {
    var err error
    db, err = sql.Open("postgres", os.Getenv("DATABASE_URL"))
    if err != nil {
        log.Fatal(err)
    }
}

// Good: explicit DI
type App struct {
    db     *sql.DB
    cache  Cache
    logger *slog.Logger
}

func NewApp(db *sql.DB, cache Cache, logger *slog.Logger) *App {
    return &App{db: db, cache: cache, logger: logger}
}
```

**Wire-up in `main.go`:**

```go
func main() {
    logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

    db, err := sql.Open("postgres", mustEnv("DATABASE_URL"))
    if err != nil {
        logger.Error("db open failed", slog.Any("error", err))
        os.Exit(1)
    }
    defer db.Close()

    cache := redis.NewClient(mustEnv("REDIS_URL"))
    userRepo  := store.NewUserRepo(db)
    userSvc   := service.NewUserService(userRepo, logger)
    userH     := handler.NewUserHandler(userSvc, logger)

    router := buildRouter(userH)
    runServer(router, logger)
}
```

---

## 4. Interface Design Rules

- Aim for **1–3 methods** per interface. The smaller, the more composable.
- Only add methods to an interface when a caller actually needs them.
- Compose small interfaces with embedding:

```go
type Reader interface {
    Read(ctx context.Context, id string) (*Resource, error)
}

type Writer interface {
    Write(ctx context.Context, r *Resource) error
    Delete(ctx context.Context, id string) error
}

// Only compose where the caller truly needs both
type ReadWriter interface {
    Reader
    Writer
}
```

- Use `interface{}` / `any` only in generic utility code. Never in domain logic.
- Verify interface compliance at compile time:

```go
var _ UserRepository = (*userRepo)(nil)
```

---

## 5. `internal/` Package Layout

Use `internal/` to prevent external packages from importing your implementation details.

```
myservice/
├── cmd/
│   └── myservice/
│       └── main.go          ← DI wiring, signal handling
├── internal/
│   ├── domain/              ← pure domain types (User, Order, etc.)
│   │   └── user.go
│   ├── service/             ← business logic + interfaces consumed
│   │   └── user.go
│   ├── store/               ← repository implementations
│   │   └── postgres/
│   │       └── user.go
│   ├── handler/             ← HTTP/gRPC handlers
│   │   └── user.go
│   ├── middleware/
│   └── config/
├── pkg/                     ← reusable utilities safe to import externally
│   ├── pagination/
│   └── validator/
├── go.mod
└── go.sum
```

**Rules:**
- `internal/domain/` contains pure Go structs with no framework dependencies.
- `internal/service/` contains business logic and defines the interfaces it consumes.
- `internal/store/` contains DB/cache implementations — never imported by `handler/` directly.
- `pkg/` is optional: only create it for genuinely reusable, stable utilities.

---

## 6. `context.Value` Keys

Always use **unexported struct types** as context keys to prevent collisions between packages.

```go
// Bad: string key can collide with any other package using "userID"
ctx = context.WithValue(ctx, "userID", id)

// Good: unexported type, impossible to collide externally
type contextKey struct{ name string }

var (
    userIDKey    = contextKey{"userID"}
    requestIDKey = contextKey{"requestID"}
    traceIDKey   = contextKey{"traceID"}
)

func WithUserID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, userIDKey, id)
}

func UserIDFromContext(ctx context.Context) (string, bool) {
    id, ok := ctx.Value(userIDKey).(string)
    return id, ok
}
```

**Rules:**
- Always provide typed getter/setter functions — never expose the key.
- Context values are for request-scoped data only (trace IDs, auth tokens, request IDs).
- Never use context to pass optional function parameters.

---

## 7. Avoid `init()` Side Effects

`init()` runs before `main()`, is untestable, and creates hidden dependencies.

**Acceptable uses:**
- Registering static lookup tables.
- Calling `flag.Register` for CLI flags.

**Never use `init()` for:**
- Opening DB connections
- Making HTTP requests
- Reading from disk
- Starting goroutines

```go
// Bad
func init() {
    db, _ = sql.Open("postgres", os.Getenv("DB_URL"))
}

// Good: explicit error handling, testable
func Connect(dsn string) (*sql.DB, error) {
    db, err := sql.Open("postgres", dsn)
    if err != nil {
        return nil, fmt.Errorf("Connect: %w", err)
    }
    if err := db.Ping(); err != nil {
        return nil, fmt.Errorf("Connect ping: %w", err)
    }
    return db, nil
}
```

---

## 8. Configuration Pattern

Prefer a typed config struct loaded once at startup, passed explicitly.

```go
type Config struct {
    Server   ServerConfig
    Database DatabaseConfig
    Redis    RedisConfig
}

type ServerConfig struct {
    Addr         string        `env:"SERVER_ADDR"         envDefault:":8080"`
    ReadTimeout  time.Duration `env:"SERVER_READ_TIMEOUT" envDefault:"10s"`
    WriteTimeout time.Duration `env:"SERVER_WRITE_TIMEOUT" envDefault:"10s"`
}

type DatabaseConfig struct {
    DSN          string `env:"DATABASE_URL,required"`
    MaxOpenConns int    `env:"DB_MAX_OPEN_CONNS" envDefault:"25"`
    MaxIdleConns int    `env:"DB_MAX_IDLE_CONNS" envDefault:"5"`
}
```

Load with `github.com/caarlos0/env/v11`:

```go
func main() {
    var cfg Config
    if err := env.Parse(&cfg); err != nil {
        slog.Error("config parse failed", slog.Any("error", err))
        os.Exit(1)
    }
    // pass cfg.Database, cfg.Server, etc. to constructors
}
```

**Rules:**
- Validate config at startup; fail fast if required values are missing.
- Pass sub-configs to the components that need them — not the entire `Config` struct.
- Never read `os.Getenv` deep inside service or repo code.

---

## 9. HTTP Handler Pattern

```go
type UserHandler struct {
    svc UserService
    log *slog.Logger
}

func NewUserHandler(svc UserService, log *slog.Logger) *UserHandler {
    return &UserHandler{svc: svc, log: log}
}

func (h *UserHandler) RegisterRoutes(r chi.Router) {
    r.Route("/users", func(r chi.Router) {
        r.Get("/{id}", h.getUser)
        r.Post("/", h.createUser)
    })
}

func (h *UserHandler) getUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")

    user, err := h.svc.GetUser(r.Context(), id)
    if err != nil {
        h.log.ErrorContext(r.Context(), "getUser failed",
            slog.String("id", id), slog.Any("error", err))
        writeError(w, err)
        return
    }

    render.JSON(w, r, user)
}
```

**Rules:**
- Handlers only: decode input, call service, encode output, handle errors.
- No business logic in handlers.
- Use `r.Context()` — never store the context.
- One error log per request, at the handler layer.
