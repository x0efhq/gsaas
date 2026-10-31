---
title: Why the code is laid out this way
weight: 13
aliases:
  - /docs/architecture/
  - /docs/project-structure/
  - /docs/services/project-structure/
  - /docs/explanation/why-this-shape/
---

# Why the code is laid out this way

gsaas is one Go program. Each feature is a package at the repository root, and `app/` is the only package that is allowed to know about all of them. That split is the whole layout.

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
├── admin/          platform-wide stats for the SaaS owner
├── platform/       shared helpers: auth, config, email, events, httpx, worker, logging
├── adapters/       Postgres and SQLite, Stripe, Supabase auth, job queue, disk storage (S3 adapter included)
├── database/       migrations, SQL queries, generated sqlc code, one directory per engine
└── cmd/            server, worker, migrate, seed
```

```
 cmd/* ──▶ app/ ──▶ identity, organization (core)
             │ ──▶ billing, projects, files, webhooks, jobs, admin ──▶ platform/
             │ ──▶ adapters/*   database/{postgres|sqlite}
   features ✗──▶ other features      (app/imports_test.go)
```

## Decisions

- **`app/` is the only package that wires everything.** You can read what runs, and in what order, in one place (`New`, `router`, `subscribe.go`, `rbac.go`, and the `jobList` in `New`).
- **Feature packages do not import each other.** One feature cannot break another feature's build. `app/imports_test.go` enforces this. `identity` and `organization` are the core exception: they import no feature, and nothing imports them back in a cycle. When billing needs a user, `app/` passes in a small interface that billing defined.
- **Adapters and database engines are imported only by `app/`.** Swapping Stripe, S3, or Postgres for SQLite is an `app/` edit. Each engine folder (`database/postgres` or `database/sqlite`) is self-contained, so you delete the one you do not use.
- **The tenant comes from the caller, not the body.** A member asks for an org in the path or in `X-Org-ID`, and `auth.Tenant` checks membership. An API key is already bound to one organization. No RLS, because the isolation tests can see the rule in Go code. Status codes are on the [API]({{< relref "/docs/reference/api.md" >}}) page.
- **Routes ask for permissions, not roles.** `app/rbac.go` is the role-to-permission table. See [Permissions]({{< relref "/docs/reference/permissions.md" >}}).
- **Auth, storage, and DB engine are code changes.** Flipping a variable would orphan stored files. Making the switch a code change keeps it deliberate.
- **Not included:** a frontend, or runtime feature toggles. Clients send a bearer token. Stripe and SMTP turn off when their variables are empty. File storage defaults to the local disk. You remove a feature by not mounting it in `app/`.
