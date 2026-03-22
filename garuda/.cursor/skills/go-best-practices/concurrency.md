# Concurrency Patterns in Go

## 1. Context Propagation

`context.Context` is always the **first parameter** of any function that does I/O, blocks, or spawns work.

```go
// Correct signatures
func (s *Service) Process(ctx context.Context, req Request) (Response, error)
func fetchPage(ctx context.Context, url string) ([]byte, error)
```

**Rules:**
- Never store a context in a struct field — pass it on each call.
- Never pass `nil` as a context. Use `context.Background()` at the program entry point.
- Always check `ctx.Err()` or use `select` with `ctx.Done()` in long loops.
- Derive child contexts to attach deadlines/values: `context.WithTimeout`, `context.WithCancel`, `context.WithValue`.

```go
// Timeout at the service boundary
func (s *Service) Fetch(ctx context.Context, id string) (*User, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel() // always defer cancel to release resources

    return s.repo.Get(ctx, id)
}
```

---

## 2. Goroutine Lifecycle Rules

Every goroutine must have a **defined termination strategy**. Leaked goroutines are a production reliability bug.

**Pattern 1: context cancellation**

```go
func (w *Worker) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return
            case job := <-w.queue:
                w.process(job)
            }
        }
    }()
}
```

**Pattern 2: quit channel**

```go
type Worker struct {
    quit chan struct{}
}

func (w *Worker) Stop() {
    close(w.quit) // broadcast to all goroutines reading from quit
}

func (w *Worker) run() {
    for {
        select {
        case <-w.quit:
            return
        case msg := <-w.input:
            w.handle(msg)
        }
    }
}
```

**Pattern 3: WaitGroup + context for fan-out**

```go
func runWorkers(ctx context.Context, n int, jobs <-chan Job) {
    var wg sync.WaitGroup
    for range n {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for {
                select {
                case <-ctx.Done():
                    return
                case j, ok := <-jobs:
                    if !ok {
                        return
                    }
                    process(j)
                }
            }
        }()
    }
    wg.Wait()
}
```

---

## 3. `errgroup` — Preferred Fan-out Primitive

Prefer `golang.org/x/sync/errgroup` over raw `sync.WaitGroup` when goroutines can fail.

```go
import "golang.org/x/sync/errgroup"

func (s *Service) EnrichAll(ctx context.Context, users []*User) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, u := range users {
        u := u // capture
        g.Go(func() error {
            profile, err := s.profileSvc.Get(ctx, u.ID)
            if err != nil {
                return fmt.Errorf("enrich user %s: %w", u.ID, err)
            }
            u.Profile = profile
            return nil
        })
    }

    return g.Wait()
}
```

**Limit concurrency with `SetLimit`:**

```go
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(10) // max 10 concurrent goroutines

for _, id := range ids {
    id := id
    g.Go(func() error {
        return process(ctx, id)
    })
}
```

---

## 4. Channel Direction Types

Always use directional channel types in function signatures to express intent:

```go
func produce(ctx context.Context) <-chan Item {
    out := make(chan Item, 16)
    go func() {
        defer close(out)
        // ... send items to out
    }()
    return out
}

func consume(ctx context.Context, in <-chan Item) error {
    for item := range in {
        if err := process(ctx, item); err != nil {
            return err
        }
    }
    return nil
}

func forward(in <-chan Item, out chan<- Item) {
    for item := range in {
        out <- item
    }
}
```

**Rules:**
- Buffer channels when producers and consumers run at different rates.
- `close(ch)` is the sender's responsibility — never close from the receiver side.
- Range over a channel `for item := range ch` — it exits cleanly when the channel is closed.
- Never send on a closed channel (panic). Use `context.Done()` to signal completion instead.

---

## 5. `sync.Mutex` vs `sync.RWMutex`

Use `sync.Mutex` for write-heavy or mixed access. Use `sync.RWMutex` when reads heavily outnumber writes.

```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]Item
}

func (c *Cache) Get(key string) (Item, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    item, ok := c.items[key]
    return item, ok
}

func (c *Cache) Set(key string, item Item) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = item
}
```

**Rules:**
- Always `defer mu.Unlock()` immediately after `mu.Lock()` — no exceptions.
- Never hold a lock across an I/O call or a channel send/receive (deadlock risk).
- Never copy a `sync.Mutex` — embed by value in a struct that is always passed by pointer.
- Prefer `sync/atomic` for single integer counters to avoid full mutex overhead.

---

## 6. `sync.Once` — Lazy Singleton Init

```go
type DB struct {
    once sync.Once
    conn *sql.DB
    err  error
}

func (d *DB) Conn() (*sql.DB, error) {
    d.once.Do(func() {
        d.conn, d.err = sql.Open("postgres", dsn)
    })
    return d.conn, d.err
}
```

Use `sync.Once` when initialization is expensive and must happen exactly once.

---

## 7. `sync.Pool` — Object Reuse

Use `sync.Pool` for frequently allocated and short-lived objects (buffers, encoder instances).

```go
var bufPool = sync.Pool{
    New: func() any {
        return new(bytes.Buffer)
    },
}

func encode(v any) ([]byte, error) {
    buf := bufPool.Get().(*bytes.Buffer)
    buf.Reset()
    defer bufPool.Put(buf)

    if err := json.NewEncoder(buf).Encode(v); err != nil {
        return nil, fmt.Errorf("encode: %w", err)
    }
    return bytes.Clone(buf.Bytes()), nil
}
```

**Rules:**
- Always `Reset()` the object before use.
- Do not store pointers to Pool objects across GC cycles — the pool may be cleared.
- Only pool objects that are actually expensive to allocate (benchmarks first).

---

## 8. `sync.Map` — Concurrent Map

Use `sync.Map` only for two specific cases:
1. Keys are written once and read many times (e.g., a registry).
2. Goroutines operate on disjoint key sets.

For general concurrent maps, a `map` + `sync.RWMutex` is clearer and often faster.

```go
var registry sync.Map

// Write once
registry.Store("handler.user", userHandler)

// Read many
if v, ok := registry.Load("handler.user"); ok {
    h := v.(http.Handler)
    h.ServeHTTP(w, r)
}
```

---

## 9. Data Race Prevention Checklist

Before shipping concurrent code, verify:

- [ ] All shared state is protected by a mutex, atomic, or channel.
- [ ] No goroutine outlives the context it was spawned with.
- [ ] Loop variable captures use `x := x` before each goroutine.
- [ ] `defer cancel()` is called for every `context.WithCancel` / `WithTimeout`.
- [ ] Channels are closed by the sender, not the receiver.
- [ ] `sync.Mutex` fields are never copied (struct is passed by pointer everywhere).
- [ ] Run `go test -race ./...` in CI.

---

## 10. Graceful Shutdown Pattern

```go
func main() {
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer stop()

    srv := &http.Server{Addr: ":8080", Handler: router}

    go func() {
        if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
            log.Fatal("server error:", err)
        }
    }()

    <-ctx.Done()
    log.Println("shutting down...")

    shutCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(shutCtx); err != nil {
        log.Fatal("forced shutdown:", err)
    }
}
```
