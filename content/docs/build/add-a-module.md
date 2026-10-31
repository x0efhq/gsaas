---
title: Add a feature
weight: 21
aliases:
  - /docs/how-to/add-a-module/
---

# Add a feature

Add a feature as its own top-level package, then connect it in `app/`. Copy `projects/`.

```
projects/
├── service.go   types, Store interface, New, business methods
├── handler.go   HTTP routes and RequirePerm gates
├── events.go    event names and payload structs
├── errors.go    sentinel errors
├── mem.go       in-memory Store for tests
└── project.go   domain type
```

1. Copy `projects/` to a new directory named after the feature. Rename the package and its types.
2. Add the table and queries for both engines you still keep. Steps are on [Add a migration]({{< relref "add-a-migration" >}}).
3. Implement the store in `database/postgres` and `database/sqlite` (or the one engine you kept), and the same methods on `NewMemStore()` in `mem.go`.
4. Construct the service in `app.New` and mount its routes in `router`, both in `app/app.go`. Copy these `projects` lines and rename:

```go
// app/app.go — in New
projectSvc := projects.New(projectStore, jobQueue, bus, clk, billingSvc, projects.Config{
	FreeMax: cfg.ProjectFreeMax,
	Plan:    billing.PlanPro,
})

// app/app.go — in router
r.With(authed, tenant).Mount("/projects", projectHandler.Routes())
```

5. Run `make check`. See [Run the tests]({{< relref "run-the-tests" >}}).

Import rules for adapters and database engines are on [Why the code is laid out this way]({{< relref "/docs/getting-started/why-this-shape.md" >}}).
