---
title: Audit log
weight: 96
---

# Audit log

The audit log records security, billing, and membership actions for an organization. Capture runs on the events bus. Request IP and user agent come from middleware (`TRUST_PROXY` affects the IP).

`GET /organizations/{orgID}/audit-logs` returns entries for that organization only. Requires `audit:read` (admins and owners). Supports `starting_after` and `limit` like other list routes.

## Entry fields

| Field | Meaning |
| --- | --- |
| `id` | Entry id |
| `org_id` | Organization id |
| `actor_user_id` | Signed-in user, when present |
| `actor_api_key_id` | API key, when present |
| `action` | Event name (see below) |
| `success` | Whether the action succeeded |
| `ip`, `user_agent` | From the request that caused the event, when present |
| `data` | JSON payload of the event |
| `created_at` | When the event occurred |

## Recorded actions

The `action` string is the bus event name. The `data` object matches the event payload.

| `action` | `success` | Notes |
| --- | --- | --- |
| `org.created` | true | New organization |
| `org.member.added` | true | Member joined |
| `org.member.removed` | true | Member removed |
| `org.member.role.changed` | true | Role changed |
| `org.api_key.created` | true | API key created |
| `org.api_key.revoked` | true | API key revoked |
| `org.api_key.auth_failed` | false | Existing key rejected (revoked, expired, or its organization was deleted) |
| `subscription.changed` | true | Stripe subscription status changed |
| `checkout.started` | true | Checkout session started |
| `auth.permission_denied` | false | Caller lacked a required permission |

These events are also written with a null `organization_id` and are not returned by the org list:

| `action` | `success` |
| --- | --- |
| `user.signed_in` | true |
| `user.signin.failed` | false |
| `user.deleted` | true |

`user.signin.failed` is published only when the email matches an existing account. `org.api_key.auth_failed` is published only when the key id exists.
