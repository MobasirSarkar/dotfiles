---
name: go-best-practices
description: Expert-level Go code generation, refactoring, and review following production-grade idioms. Use when writing, reviewing, or debugging Go code; generating services, HTTP handlers, repositories, middleware, or tests; or when the user mentions Go, Golang, idiomatic Go, goroutines, channels, interfaces, or Go error handling.
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
// Bad
if err == nil {
    doWork()
} else {
    return err
}

// Good
if err != nil {
    return fmt.Errorf("doing work: %w", err)
}
doWork()
```

- Keep the happy path left-aligned. Every early return reduces nesting.
- Functions should do one thing. If you need a comment to explain a block, extract a function.

## 3. Error Handling

See [error-handling.md](error-handling.md) for full production patterns.

**Quick rules:**
- Never discard errors with `_` unless the function is provably infallible.
- Wrap with context at every layer boundary: `fmt.Errorf("repo.GetUser: %w", err)`.
- Check with `errors.Is` / `errors.As`, never string comparison.
- Log errors at the boundary (handler/service entry point) — not deep in the stack.

## 4. Concurrency

See [concurrency.md](concurrency.md) for full patterns.

**Quick rules:**
- `context.Context` is always the first argument: `func (s *Service) Fetch(ctx context.Context, id string)`.
- Every goroutine must have a defined termination strategy.
- Prefer `errgroup.WithContext` over raw `sync.WaitGroup`.
- Use channels for data flow; mutexes for protecting state.

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

## 7. Interfaces

See [patterns.md](patterns.md) for full design patterns.

**Quick rules:**
- Prefer 1–3 method interfaces (`io.Reader`, `io.Writer`).
- Define interfaces where they are *consumed*, not where implementations live.
- Don't create interfaces speculatively. Add one only when you have ≥2 concrete implementations or need to mock for testing.

## 8. Testing

See [testing.md](testing.md) for full strategies.

**Quick rules:**
- All tests are table-driven with `t.Run`.
- Use `t.Parallel()` for independent unit tests.
- Use `require` (fatal) for setup/preconditions; `assert` (non-fatal) for assertions.
- Use `//go:build integration` tag to separate slow integration tests.

## Additional Resources

- [error-handling.md](error-handling.md) — Sentinel errors, custom types, wrapping, errgroup, panic policy
- [concurrency.md](concurrency.md) — Goroutine lifecycle, context, channels, sync primitives
- [testing.md](testing.md) — Table-driven, fuzz, benchmarks, testify, mocks
- [patterns.md](patterns.md) — Functional options, repository, DI, internal layout
