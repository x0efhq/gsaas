---
title: Run the tests
weight: 24
aliases:
  - /docs/testing/
  - /docs/services/testing/
  - /docs/how-to/run-the-tests/
---

# Run the tests

From the repository root, run:

```bash
make check
```

`make check` is the definition of done. It runs `gofmt`, `go vet ./...`, `go test ./...`, and a diff of `sqlc` output against `database/*/sqlc`. If `sqlc` is not installed, that last step prints a skip message and the rest still runs.

The command exits 0 when every step passes. A formatting failure prints the paths. A stale `database/*/sqlc` tells you to run `make sqlc-gen`.

| Command | What it runs |
| --- | --- |
| `make check` | format, vet, `go test ./...`, sqlc diff |
| `make test` | `go test ./...` only |
| `go test ./projects/` | one package |

Module tests use the in-memory stores in each `mem.go`. They do not need Postgres. SQLite store tests always run, each on a temporary file. Postgres store tests under `database/postgres` run only when `TEST_DATABASE_URL` is set. Point it at a disposable database. Those tests write to it. Do not point it at the database the API is using.

The tests expect the schema to exist. Create the test database once, then apply the migrations to it before `make check`, the same as CI. With the Compose Postgres:

```bash
make postgres
docker compose exec postgres createdb -U app app_test
export TEST_DATABASE_URL='postgres://app:app@localhost:5432/app_test?sslmode=disable'
DATABASE_URL=$TEST_DATABASE_URL go run ./cmd/migrate up
make check
```

Run the migrate line again after you change a migration.

| Test | Fails when |
| --- | --- |
| `app/imports_test.go` | a package imports across the boundary (see [Why the code is laid out this way]({{< relref "/docs/getting-started/why-this-shape.md" >}})) |
| `app/isolation_test.go` | a tenant route has no cross-tenant case |
| `app/openapi_test.go` | a mounted route is missing from `app/openapi.yaml` |
