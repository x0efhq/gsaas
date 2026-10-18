---
title: Testing
weight: -9
---

# Testing

Code: `*_test.go` next to each package; tenant isolation in `app/isolation_test.go`

The test suite runs without a database or external services. One command, `make check`, tells you whether a change is done.

**What you get**

- **No database needed.** Module tests use the in-memory stores in each `mem.go`.
- **Tenant isolation tests.** One organization can't reach another's data, checked on every tenant route.
- **API spec check.** Every mounted route must be in `app/openapi.yaml`.
- **Architecture check.** Package import rules are enforced by a test.
- **CI included.** Pull requests run `make check`.

## Run the tests

```bash
make check
```

`make check` is the definition of done. It runs:

1. `gofmt` (fails if any file needs formatting)
2. `go vet ./...`
3. `go test ./...`
4. `sqlc generate` into a temporary directory and a diff against `database/sqlc`, which fails if the generated code is stale. This step is skipped with a message if `sqlc` isn't installed.

`make test` runs only `go test ./...`. To run one package, use `go test ./projects/`.

CI (`.github/workflows/check.yml`) installs sqlc v1.30.0 and runs `make check` on pull requests.

## What the tests cover

- Module tests run against the in-memory stores in each `mem.go`, so they need no database.
- Postgres store tests in `adapters/postgres` are skipped unless `DATABASE_URL` is set in the shell. They don't run in CI.
- `app/imports_test.go` enforces the package import rules.
- `app/isolation_test.go` checks that one organization can't reach another's data. It fails until every route under a tenant prefix is covered.
- `app/openapi_test.go` fails for any mounted route missing from `app/openapi.yaml`.

## Test helpers

- `worker.NewMem()` records enqueued jobs instead of running them.
- `events.NewMem` is an in-memory event bus.
