---
title: How to add a module
weight: 1
---

# How to add a module

Add a feature as its own top-level package, then connect it in `app/`. Copy `projects/`. That package is the sample shape: `service.go`, `handler.go`, `events.go`, `errors.go`, and `mem.go`.

`service.go` holds the types, the `Store` interface, and `New`. It does not import `net/http`.

1. Copy `projects/` to a new directory named after the feature. Rename the package and its types.
2. Add a migration for a new table as `database/postgres/migrations/0000N_<name>.sql`. Add `-- name:` queries in that file, then run `make sqlc-gen`.
3. Implement the store in `adapters/postgres` and the same methods on `NewMemStore()` in `mem.go`.
4. Construct the service in `app.New` and mount its routes in `router`, both in `app/app.go`. Follow the `projects` lines already there.
5. Run `make check`.

Only `app/` imports `adapters/`. A domain package imports no other domain except the core packages `identity` and `organization`. `app/imports_test.go` fails the build when that rule breaks.

Why wiring lives in `app/` is on [Why the code is arranged this way]({{< relref "why-this-shape" >}}).
