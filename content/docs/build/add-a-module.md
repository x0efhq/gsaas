---
title: How to add a module
weight: 21
aliases:
  - /docs/how-to/add-a-module/
---

# How to add a module

Add a feature as its own top-level package, then connect it in `app/`. Copy `projects/`. That package is the sample shape: `service.go`, `handler.go`, `events.go`, `errors.go`, and `mem.go`.

`service.go` holds the types, the `Store` interface, and `New`. It does not import `net/http`.

1. Copy `projects/` to a new directory named after the feature. Rename the package and its types.
2. Add the table and queries for both engines you still keep. Steps are on [How to add a migration]({{< relref "add-a-migration" >}}).
3. Implement the store in `database/postgres` and `database/sqlite` (or the one engine you kept), and the same methods on `NewMemStore()` in `mem.go`.
4. Construct the service in `app.New` and mount its routes in `router`, both in `app/app.go`. Follow the `projects` lines already there.
5. Run `make check`. See [How to run the tests]({{< relref "run-the-tests" >}}).

Only `app/` imports `adapters/`, and only `app/` and `cmd/` import the `database/` engines. Why that rule exists is on [Why this shape]({{< relref "/docs/getting-started/why-this-shape.md" >}}).
