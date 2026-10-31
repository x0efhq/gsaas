---
title: Platform admin (your own staff)
weight: 97
aliases:
  - /docs/admin/
  - /docs/services/admin/
---

# Platform admin (your own staff)

A platform admin operates the installation. The flag `is_platform_admin` adds platform permissions to that user's session. Organization roles and API keys never grant them. See [Permissions]({{< relref "permissions" >}}).

| Permission | Route |
| --- | --- |
| `platform:stats` | `GET /admin/stats` |
| `platform:users:list` | `GET /users` |
| `platform:users:manage` | `GET` and `PATCH /users/{id}` for any user |

`make seed` sets the flag on `admin@local` (override with `SEED_ADMIN_*`). In a deployed database:

```sql
UPDATE users SET is_platform_admin = true WHERE email = 'you@example.com';
```

The next request from that user picks it up. A new sign-in is not required.

## Stats

`GET /admin/stats` takes no `X-Org-ID`. Anyone else receives 403. Code: `admin/`. Grant table: `platformAdminPerms` in `app/rbac.go`.

```json
{
  "object": "admin_stats",
  "data": {
    "users": { "total": 120, "new_7d": 9, "new_30d": 31, "active_7d": 44, "active_30d": 70 },
    "organizations": { "total": 18, "new_7d": 2, "new_30d": 5 },
    "projects": { "total": 52 },
    "subscriptions": {
      "active": 11, "trialing": 3, "past_due": 1, "canceled": 2
    },
    "webhooks": { "deliveries_24h": 230, "succeeded_24h": 226 },
    "jobs": { "failed_24h": 1 }
  }
}
```

| Field | Meaning |
| --- | --- |
| `users.total` | Users, excluding deleted |
| `users.new_7d`, `users.new_30d` | Users created in the window |
| `users.active_7d`, `users.active_30d` | A session was issued in the window (sign-in, magic link, or refresh). `active_30d` only reaches as far as `REFRESH_TTL`. Supabase sessions are not counted, so those counts stay 0 |
| `organizations` | Team organizations only. Personal organizations match users one to one and are not included |
| `projects.total` | Projects across all organizations |
| `subscriptions` | One count per status that has subscriptions. A status with none is left out |
| `webhooks.deliveries_24h`, `webhooks.succeeded_24h` | Deliveries created in the last 24 hours, and how many succeeded |
| `jobs.failed_24h` | Jobs created in the last 24 hours whose status is now `failed`. Jobs stopped with `worker.ErrPermanent` end `canceled` and are not counted. See [Jobs]({{< relref "jobs" >}}) |
