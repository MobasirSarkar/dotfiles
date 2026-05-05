# Testing Strategies in Go

## 1. Table-Driven Tests

All tests with multiple scenarios must be table-driven using anonymous structs + `t.Run`.

```go
func TestAdd(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name    string
        a, b    int
        want    int
    }{
        {name: "positive numbers", a: 2, b: 3, want: 5},
        {name: "negative numbers", a: -1, b: -1, want: -2},
        {name: "zero identity",    a: 0, b: 5,  want: 5},
    }

    for _, tc := range tests {
        tc := tc // capture
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            got := Add(tc.a, tc.b)
            assert.Equal(t, tc.want, got)
        })
    }
}
```

**Rules:**
- `name` field must be present and descriptive — it becomes the subtest path in output.
- Capture loop variable (`tc := tc`) before spawning parallel subtests.
- Group fields logically: inputs first, then expected outputs, then optional error.

---

## 2. `t.Parallel()` Usage

- Call `t.Parallel()` at the top of every independent unit test.
- Call `t.Parallel()` inside subtests when subtests are independent.
- Do **not** call `t.Parallel()` for tests that modify shared state (files, DB rows, global vars).
- Integration tests that share a DB transaction should **not** be parallel unless using test-level DB isolation.

```go
func TestUserService_Create(t *testing.T) {
    t.Parallel() // safe: each test gets its own in-memory DB
    // ...
}
```

---

## 3. `testify/require` vs `testify/assert`

| Package | Behavior | When to Use |
|---|---|---|
| `require` | Stops test immediately (like `t.FailNow`) | Setup, preconditions, single critical assertion |
| `assert` | Records failure, continues test | Multiple independent assertions per test |

```go
func TestGetUser(t *testing.T) {
    t.Parallel()

    svc := newTestService(t)

    // require: if svc is nil the rest cannot proceed
    require.NotNil(t, svc)

    user, err := svc.GetUser(context.Background(), "123")
    require.NoError(t, err)     // fatal: no point checking user if err != nil

    assert.Equal(t, "123", user.ID)
    assert.Equal(t, "Alice", user.Name)
    assert.False(t, user.Disabled)
}
```

---

## 4. Test Helpers with `t.Helper()`

Mark helper functions with `t.Helper()` so failures report the caller's line, not the helper's.

```go
func assertUserEqual(t *testing.T, want, got *User) {
    t.Helper()
    assert.Equal(t, want.ID, got.ID, "user ID mismatch")
    assert.Equal(t, want.Name, got.Name, "user name mismatch")
    assert.Equal(t, want.Email, got.Email, "user email mismatch")
}

func newTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite3", ":memory:")
    require.NoError(t, err)
    t.Cleanup(func() { db.Close() })
    return db
}
```

**Use `t.Cleanup` instead of `defer` in helpers** — it runs even if the test panics and works correctly with `t.Parallel()`.

---

## 5. `testdata/` Directory Convention

Store test fixtures (JSON, SQL, golden files) under `testdata/` relative to the package:

```
store/
├── user.go
├── user_test.go
└── testdata/
    ├── fixtures/
    │   ├── user_create.json
    │   └── user_list.golden
    └── migrations/
        └── seed.sql
```

Load fixtures in tests:

```go
func loadFixture(t *testing.T, name string) []byte {
    t.Helper()
    data, err := os.ReadFile(filepath.Join("testdata", name))
    require.NoError(t, err)
    return data
}
```

**Golden file pattern** for complex expected outputs:

```go
func TestRender(t *testing.T) {
    t.Parallel()

    got := render(input)
    golden := filepath.Join("testdata", "render.golden")

    if *update { // -update flag regenerates golden files
        require.NoError(t, os.WriteFile(golden, []byte(got), 0o644))
        return
    }

    want, err := os.ReadFile(golden)
    require.NoError(t, err)
    assert.Equal(t, string(want), got)
}

var update = flag.Bool("update", false, "update golden files")
```

---

## 6. Interface Mocks

**Prefer handwritten minimal mocks or `mockery` over heavy frameworks.**

**Handwritten mock:**

```go
type mockUserRepo struct {
    getFunc func(ctx context.Context, id string) (*User, error)
    calls   []string
}

func (m *mockUserRepo) Get(ctx context.Context, id string) (*User, error) {
    m.calls = append(m.calls, id)
    if m.getFunc != nil {
        return m.getFunc(ctx, id)
    }
    return nil, nil
}
```

**Usage:**

```go
func TestService_GetUser_NotFound(t *testing.T) {
    t.Parallel()

    repo := &mockUserRepo{
        getFunc: func(ctx context.Context, id string) (*User, error) {
            return nil, ErrNotFound
        },
    }
    svc := NewUserService(repo)

    _, err := svc.GetUser(context.Background(), "missing-id")
    require.Error(t, err)
    assert.ErrorIs(t, err, ErrNotFound)
}
```

**`mockery` generation** (when the interface is large):

```bash
mockery --name=UserRepository --dir=./internal/store --output=./internal/store/mocks --outpkg=mocks
```

Then in tests:

```go
import "yourmodule/internal/store/mocks"

repo := mocks.NewUserRepository(t) // auto-cleanup via t.Cleanup
repo.On("Get", mock.Anything, "123").Return(&User{ID: "123"}, nil)
```

---

## 7. Fuzz Testing (Go 1.18+)

```go
func FuzzParseUserID(f *testing.F) {
    // Seed corpus
    f.Add("user-123")
    f.Add("usr_abc")
    f.Add("")

    f.Fuzz(func(t *testing.T, input string) {
        // Must not panic
        id, err := ParseUserID(input)
        if err != nil {
            return // invalid input is fine
        }
        // Round-trip invariant
        assert.Equal(t, input, id.String())
    })
}
```

Run: `go test -fuzz=FuzzParseUserID -fuzztime=30s ./...`

**Rules:**
- Fuzz functions must never panic on any input.
- Check invariants, not exact outputs (the fuzzer generates arbitrary inputs).
- Commit crash inputs in `testdata/fuzz/<FuzzFuncName>/` to replay regressions.

---

## 8. Benchmarks

```go
func BenchmarkJSONEncode(b *testing.B) {
    user := &User{ID: "123", Name: "Alice", Email: "alice@example.com"}

    b.ReportAllocs() // show allocations per op
    b.ResetTimer()   // exclude setup time

    for b.Loop() {  // Go 1.24+: b.Loop() is preferred over range b.N
        _, err := json.Marshal(user)
        if err != nil {
            b.Fatal(err)
        }
    }
}
```

**Sub-benchmarks for parameter sweeps:**

```go
func BenchmarkCache_Get(b *testing.B) {
    for _, size := range []int{100, 1_000, 10_000} {
        b.Run(fmt.Sprintf("size=%d", size), func(b *testing.B) {
            c := buildCache(size)
            b.ResetTimer()
            for b.Loop() {
                c.Get("key-50")
            }
        })
    }
}
```

Run: `go test -bench=. -benchmem -count=5 ./...`

Compare with `benchstat`: `benchstat old.txt new.txt`

---

## 9. Integration vs Unit Separation

Use build tags to separate slow integration tests:

```go
//go:build integration

package store_test

import (
    "testing"
    // ...
)

func TestUserRepo_Integration(t *testing.T) {
    // requires real DB
}
```

Run unit tests: `go test ./...`
Run integration tests: `go test -tags=integration ./...`

**Database integration with `testcontainers-go`:**

```go
func newTestPostgres(t *testing.T) *sql.DB {
    t.Helper()

    ctx := context.Background()
    container, err := postgres.Run(ctx, "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections"),
        ),
    )
    require.NoError(t, err)
    t.Cleanup(func() { container.Terminate(ctx) })

    dsn, err := container.ConnectionString(ctx, "sslmode=disable")
    require.NoError(t, err)

    db, err := sql.Open("postgres", dsn)
    require.NoError(t, err)
    t.Cleanup(func() { db.Close() })

    return db
}
```

---

## 10. Test Coverage & CI Rules

- Run `go test -race ./...` in every CI pipeline — the race detector catches real production bugs.
- Track coverage but don't chase 100%: cover critical paths (service logic, error branches).
- Use `go test -coverprofile=cover.out ./... && go tool cover -html=cover.out` for visual analysis.
- Minimum enforced coverage thresholds (example):
  - `internal/service/`: ≥ 80%
  - `internal/handler/`: ≥ 70%
  - `cmd/`: no enforcement
