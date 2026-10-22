---
title: How to run the tests
weight: 3
---

# How to run the tests

From the repository root, run:

```bash
make check
```

`make check` is the definition of done. It runs `gofmt`, `go vet ./...`, `go test ./...`, and a diff of `sqlc` output against `database/sqlc`. If `sqlc` is not installed, that last step prints a skip message and the rest still runs.

The command exits 0 when every step passes. A formatting failure prints the paths. A stale `database/sqlc` tells you to run `make sqlc-gen`.

To run one package:

```bash
go test ./projects/
```

`make test` runs `go test ./...` and skips the format, vet, and sqlc steps.

Module tests use the in-memory stores in each `mem.go`. They do not need Postgres. Store tests under `adapters/` run only when `TEST_DATABASE_URL` is set. Point it at a disposable database. Those tests write to it. Do not point it at the database the API is using.

```bash
TEST_DATABASE_URL=postgres://user:pass@localhost:5432/gsaas_test make check
```

What each suite asserts is on the [Testing]({{< relref "testing" >}}) page.
