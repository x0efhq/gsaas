---
title: API
weight: 1
---

# API

The running server publishes the full description of every route.

| URL | Body |
| --- | --- |
| `GET /docs` | Interactive reference |
| `GET /openapi.yaml` | OpenAPI 3.1 document |

On a local server those paths are `http://localhost:5000/docs` and `http://localhost:5000/openapi.yaml`.

## Authentication

Send `Authorization: Bearer <token>` on every route that requires a caller.

| Token | Form |
| --- | --- |
| Session access token | Signed JWT from sign-in or refresh |
| Organization API key | Prefixed `ak_` |

A route marked user rejects an API key. A route marked user or API key accepts either.

## Tenant

Routes whose prefix is in `tenantPrefixes` act on one organization.

| How the org is chosen | When |
| --- | --- |
| `{orgID}` in the path | The path contains an organization id |
| `X-Org-ID` header | The path has no organization id |

The organization is not taken from the request body. A caller who is not a member of that organization receives 403. A path id for an object in another organization receives 404.

## Route groups

| Prefix | Caller |
| --- | --- |
| `GET /healthz`, `GET /readyz` | none |
| `/auth` | none; rate limited per IP |
| `POST /invites/accept` | none; rate limited per IP |
| `/me` | user |
| `GET /users`, `GET /users/{id}`, `PATCH /users/{id}` for a user other than the caller | user with `platform:users:list` or `platform:users:manage` |
| `/files` | user |
| `POST /organizations` | user |
| `/organizations/{orgID}` | user or API key; tenant |
| `/organizations/{orgID}/billing` | user; tenant |
| `/organizations/{orgID}/webhooks` | user or API key; tenant |
| `/projects` | user or API key; tenant; `X-Org-ID` |
| `/jobs` | user or API key; tenant; `X-Org-ID` |
| `GET /admin/stats` | user with `platform:stats` |
| `POST /webhooks/stripe` | Stripe signature |

## Bodies

| Kind | Shape |
| --- | --- |
| One object | `{"object": "<type>", "data": { }}` |
| List | `{"object": "list", "data": [], "has_more": false, "starting_after": ""}` |
| Error | `{"object": "error", "error": {"type": "", "message": ""}}` |

List requests take `starting_after`. `has_more` is true when another page exists.

## Limits

Authenticated routes are limited per minute by `API_RATE_LIMIT` (default 300). The counter is the API key, otherwise the user, otherwise the client IP. Public `/auth` and `POST /invites/accept` are limited per minute per IP by `AUTH_RATE_LIMIT`.

A request over the limit receives 429 and a `Retry-After` header.
