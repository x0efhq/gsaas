---
title: Platform admin
weight: -6
---

# Platform admin

Code: `admin/`, grant in `app/rbac.go` (`platformAdminPerms`)

A platform admin is you, the SaaS owner, not an org role. Users with `is_platform_admin`
get platform perms (`platform:stats`, `platform:users:list` for `GET /users`) on their
session. API keys never get them, even a
key created by a platform admin, and no org role can grant them.

## Becoming a platform admin

- Locally, `make seed` creates `admin@local` / `password` as a platform admin
  (change it with `SEED_ADMIN_*`).
- In production, sign up normally, then set the flag in the database:
  `UPDATE users SET is_platform_admin = true WHERE email = 'you@example.com';`
  It applies on your next request; no new sign-in needed.

## Stats

`GET /admin/stats` returns platform-wide counts for your dashboard. It is not org-scoped,
so send no `X-Org-ID`. Others get 403.

```json
{
  "object": "admin_stats",
  "data": {
    "users": { "total": 120, "new_7d": 9, "new_30d": 31, "active_7d": 44, "active_30d": 70 },
    "organizations": { "total": 18, "new_7d": 2, "new_30d": 5 },
    "projects": { "total": 52 },
    "subscriptions": {
      "active": 11, "trialing": 3, "past_due": 1, "canceled": 2,
      "incomplete": 0, "unpaid": 0, "paused": 0
    },
    "webhooks": { "deliveries_24h": 230, "succeeded_24h": 226 },
    "jobs": { "failed_24h": 1 }
  }
}
```

- **users**: deleted users excluded. Active means a session was issued in the window
  (sign-in, magic link or token refresh). Expired sessions are cleaned up, so
  `active_30d` only looks back as far as `REFRESH_TTL` (default 7 days). Supabase Auth
  sessions aren't tracked, so active counts stay 0 there.
- **organizations**: team organizations only; personal workspaces match users one to one.
- **subscriptions**: every status is present, zero when unused.
- **webhooks**: deliveries created in the last 24 hours, and how many succeeded.
- **jobs**: jobs of every organization, system jobs included, created in the last 24
  hours and now `failed` (out of retries). A job created earlier that fails today isn't
  counted. Jobs stopped with `worker.ErrPermanent` end
  `canceled` and aren't counted.
