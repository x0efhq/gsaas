---
title: Organizations & multi-tenancy
weight: -16
---

# Organizations & multi-tenancy

Code: `organization/`, `platform/auth/`, `app/rbac.go`

An organization (org) is a tenant: an account whose data is kept separate from every other org. Every user gets a **personal org** they alone own; they can also create **team orgs** and invite others. Each member has a role, and the role decides what they can do.

## Who can do what

| Action | viewer | member | admin | owner |
| --- | --- | --- | --- | --- |
| Read the org, list and read projects | ✓ | ✓ | ✓ | ✓ |
| List members | ✓ | ✓ | ✓ | ✓ |
| Leave the org | ✓ | ✓ | ✓ | ✗ |
| List and read jobs | ✗ | ✓ | ✓ | ✓ |
| Cancel jobs | ✗ | ✗ | ✓ | ✓ |
| Create, update and delete projects | ✗ | ✗ | ✓ | ✓ |
| Update the org | ✗ | ✗ | ✓ | ✓ |
| Manage billing | ✗ | ✗ | ✓ | ✓ |
| Invite members, list and revoke invites | ✗ | ✗ | ✓ | ✓ |
| Change member roles, remove members | ✗ | ✗ | ✓ | ✓ |
| Manage API keys | ✗ | ✗ | ✓ | ✓ |
| Manage webhooks | ✗ | ✗ | ✓ | ✓ |
| Delete the org | ✗ | ✗ | ✗ | ✓ |

Billing, deleting the org, invites, API keys and leaving also need a signed-in user; an API key (a secret token for server-to-server calls) can't use them.

## Protecting a route

Put a guard (middleware that returns 403 when the caller lacks the permission) in front of the route. Inside a module, `NewHandler(s, guard)` stores it on the handler as `h.guard`; in `app.go` you use `guard` directly.

```go
// Module handler: callers holding the permission
r.With(h.guard.RequirePerm(projects.PermWrite)).Post("/", h.Create)

// Your own route, signed-in admins and owners only (illustrative)
r.With(guard.RequireRole(org.RoleAdmin)).Post("/", h.Create)
```

To add a permission, define an `auth.Perm` constant in your module and add it to the lowest role that should have it in `app/rbac.go`.

## Choosing the organization

Every user gets a personal org, created at sign-up, first Supabase sign-in, or invite acceptance. Data in tenant modules such as projects, jobs, billing and webhooks belongs to one org.

Routes with `{orgID}` in the path use that org. Other tenant routes, such as `/projects` and `/jobs`, read the `X-Org-ID` header. The tenant middleware checks membership, so a user who isn't a member gets 403. Isolation is enforced in app code and covered by `app/isolation_test.go`.

## Tenant middleware

The `tenant` middleware resolves the org (`{orgID}` path, else `X-Org-ID`), checks the caller is a member and sets their role. An API key belongs to one org and keeps its own perms; with no org named it uses its own org, and naming another org gets 403.

## RequirePerm vs RequireRole

- `RequirePerm(p)` allows callers holding `p`: members whose role is granted it in `app/rbac.go`, or API keys created with it. Built-in routes use it.
- `RequireRole(min)` allows signed-in members ranked at or above `min` in `org.Roles`. It's a session-only shortcut for your own routes; API keys have no role, so they get 403.

Both return 401 when there is no caller and 403 when the caller lacks the permission.

## Organization routes

| Route | Purpose |
| --- | --- |
| `GET /me/organizations` | List the orgs you belong to, with your role in each (user only) |
| `POST /organizations` | Create an organization |
| `GET /organizations/{orgID}` | Read it |
| `PATCH /organizations/{orgID}` | Update it (`org:update`) |
| `DELETE /organizations/{orgID}` | Delete it (owners only) |

A personal organization takes no invites and can't be deleted through this route. It is deleted with its owner's account.

## Members

| Route | Purpose |
| --- | --- |
| `GET /organizations/{orgID}/members` | List members (`org:members:read`) |
| `PATCH /organizations/{orgID}/members/{userID}` | Change a member's role (`org:members:manage`) |
| `DELETE /organizations/{orgID}/members/{userID}` | Remove a member (`org:members:manage`) |
| `DELETE /organizations/{orgID}/members/me` | Leave the org (user only) |

```json
PATCH /organizations/{orgID}/members/{userID}
{"role": "admin"}
```

Every org has exactly one owner. Nobody can be given the owner role, and the owner can't be demoted, removed or leave: those requests get 409.

## Invites

| Route | Purpose |
| --- | --- |
| `POST /organizations/{orgID}/invites` | Invite by email with a role |
| `GET /organizations/{orgID}/invites` | List pending invites |
| `DELETE /organizations/{orgID}/invites/{inviteID}` | Revoke an invite |
| `POST /invites/accept` | Accept an invite |
| `GET /invites/accept?token=...` | Confirm page for the emailed link, when you have no frontend |

Invites need `org:members:invite`, can't grant the owner role, and expire after `INVITE_TTL`. The invitee gets an email with the invite link; see [Emailed links]({{< relref "authentication#emailed-links" >}}) for what your frontend does with it. Accepting signs the invitee in.
