---
title: Why the code is arranged this way
weight: 1
aliases:
  - /docs/architecture/
  - /docs/project-structure/
  - /docs/services/project-structure/
---

# Why the code is arranged this way

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
├── adapters/       database, Stripe, Supabase auth, job queue, disk storage (S3 adapter included)
├── database/       migrations, SQL queries, generated sqlc code
└── cmd/            server, worker, migrate, seed
```

## One place wires the process

A reader, or a coding agent, should be able to answer "what runs, and in what order" by opening `app/`. `New` constructs the services. `router` mounts the routes. `subscribe.go` attaches event handlers. `rbac.go` turns a member's role into permissions. `jobs()` names every background job.

If those connections were spread through the feature packages, adding a feature would mean hunting for the hidden call. Keeping them in `app/` makes a new feature a new package plus a few lines in that one place. The cost is that `app/` is large and boring. That cost is the point.

## Features do not call each other

A feature package does not import another feature package. `identity` and `organization` are the exception, and nothing imports them back in a cycle: they are the core, and they import no feature. When billing needs a user, `app/` passes in a small interface that billing defined.

The rule is there so a change in one feature does not compile-break the others, and so an agent cannot quietly reach into a package it was not given. `app/imports_test.go` fails when a package crosses the line. Adapters (Postgres, Stripe, S3, Supabase) sit behind that same wall: only `app/` imports them, so swapping a provider is a change in `app/`, not a change in the feature.

## The organization comes from the caller

Tenant data is filtered by the organization on the authenticated caller. Handlers do not trust an organization id in the JSON body. A member asks for an org in the path or in `X-Org-ID`, and `auth.Tenant` checks that they belong to it before the handler runs. An API key has no choice: it is already bound to one organization.

This is ordinary application code, not Postgres row-level security. Row-level security would hide the same rule inside the database, where the tests in this repository cannot see it and a query written by mistake can still be wrong in a way the type system will not catch. The isolation tests call the service with two organizations and expect a 403 or a 404. The rule stays visible next to the route.

## Permissions are not roles at the door

Roles belong to an organization: owner, admin, member, viewer. The platform checks permissions. `app/rbac.go` is the table that maps a role to the permissions it grants. A route asks for a permission, not for a role, so a new route does not invent a new role.

API keys hold permissions and no role. A person creating a key cannot grant a permission their own role lacks. Platform-admin permissions (`platform:stats` and the user-management permissions) are not in any organization role. They are added to a platform admin's session, and they are never placed on an API key.

## What this leaves out

The layout does not include a frontend. Clients send a bearer token. It also does not try to make every feature optional at runtime. Stripe and SMTP turn off when their variables are empty. File storage is the local disk. The packages are still in the binary. Removing a feature means not mounting it, which is again a change in `app/`.

Auth and file storage are not settings. You switch them in `app.New`. A saved file key exists only in the store that wrote it, so flipping a variable on a running deployment would orphan every stored file. Making the switch a code change keeps it deliberate. A future project generator will make that edit for you.
