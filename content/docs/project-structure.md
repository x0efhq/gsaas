---
title: Project structure
weight: -18
aliases: ["/docs/architecture/"]
---

# Project structure

Code: `app/` wires everything together; each feature has its own folder, such as `projects/` or `billing/`

gsaas is a modular monolith: one Go binary where each feature (module) is its own top-level package with the same layout. All wiring happens in one place, `app/`, so a new feature is a new package plus a few lines there.

## Add your own feature

Copy `projects/`, the sample module. `AGENTS.md` in the repository has the step-by-step recipes for modules, endpoints, events, jobs and migrations.

## Layout

```
gsaas/
├── app/            composition root: wiring, routes, event subscriptions, jobs
├── identity/       users, sign-in, sessions, magic links
├── organization/   organizations, members, invites, roles, API keys
├── billing/        plans, checkout, subscriptions
├── projects/       sample module to copy for your own features
├── webhooks/       outbound webhooks
├── files/          file uploads
├── jobs/           job status, list and cancel API
├── platform/       shared helpers: auth, config, email, events, httpx, jobs, log
├── adapters/       Postgres, Stripe, Supabase, job queue, S3 storage
├── database/       migrations, SQL queries, generated sqlc code
└── cmd/            server, worker, migrate, seed
```

## Modules

Each module (domain) is a top-level package with the same shape:

| File | Contents |
| --- | --- |
| `<name>.go` | Domain types, for example `projects/project.go` |
| `service.go` | Types, the `Store` interface, `Service` and `New`. No `net/http`. |
| `handler.go` | `NewHandler` and `Routes()` |
| `events.go` | Event names and payloads |
| `errors.go` | Exported error sentinels (fixed error values such as `ErrNotFound`), checked with `errors.Is` |
| `mem.go` | In-memory `Store` used by tests |
| `*_test.go` | Tests |

The Postgres implementation of each store lives in `adapters/postgres/`. Only `app/` imports adapters, so swapping a provider means swapping an adapter. `app/imports_test.go` enforces these import rules.

## The app package

`app/` is the composition root: the one place that constructs every component and connects them. `app/app.go` builds every component in `New` and mounts routes in `router`. `app/subscribe.go` registers event handlers, and `app/rbac.go` builds the `auth.Guard` from `org.Roles` and the permissions each role adds. Nothing is wired anywhere else.

## Events

Modules publish typed events on an in-process bus (`platform/events`, an in-memory publish/subscribe channel: publishers don't know who listens) after a write succeeds, for example `projects.EventCreated`. Handlers in `app/subscribe.go` send emails, record analytics, and forward selected events to [outbound webhooks]({{< relref "webhooks" >}}).

An event in `projects/events.go`, published in `projects/service.go`:

```go
const EventCreated = "project.created"

type Created struct {
	ID    uuid.UUID `json:"id"`
	OrgID uuid.UUID `json:"org_id"`
	Name  string    `json:"name"`
}

events.Publish(s.bus, ctx, EventCreated, Created{ID: p.ID, OrgID: p.OrgID, Name: p.Name})
```

## Responses

Handlers use the `platform/httpx` writers:

- A single object: `{"object": ..., "data": ...}`
- A list: `{"object": "list", "data": [], "has_more": ..., "starting_after": ...}`
- An error: `{"object": "error", "error": {"type": ..., "message": ...}}`

Lists use cursor pagination with `starting_after` and `has_more`.
