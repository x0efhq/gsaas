---
title: Platform admin
weight: 6
aliases:
  - /docs/admin/
  - /docs/services/admin/
---

# Platform admin

A platform admin is the operator of the installation, not an organization role. The flag `is_platform_admin` adds these permissions to that user's session. No organization role grants them. An API key never has them.

| Permission | Route |
| --- | --- |
| `platform:stats` | `GET /admin/stats` |
| `platform:users:list` | `GET /users` |
| `platform:users:manage` | `GET` and `PATCH /users/{id}` for any user |

`make seed` sets the flag on `admin@local`. In a deployed database:

```sql
UPDATE users SET is_platform_admin = true WHERE email = 'you@example.com';
```

The next request from that user picks it up. A new sign-in is not required.

`GET /admin/stats` takes no `X-Org-ID`. Anyone else receives 403.

| Field | Meaning |
| --- | --- |
| `users.total` | Users, excluding deleted |
| `users.active_7d`, `users.active_30d` | A session was issued in the window. `active_30d` only reaches as far as `REFRESH_TTL`. Supabase sessions are not counted, so those counts stay 0 |
| `organizations` | Team organizations. Personal organizations are not included |
| `subscriptions` | One count per status, zero when unused |
| `webhooks.deliveries_24h` | Deliveries created in the last 24 hours |
| `jobs.failed_24h` | Jobs created in the last 24 hours whose status is now `failed`. A job canceled with `worker.ErrPermanent` is not included |
