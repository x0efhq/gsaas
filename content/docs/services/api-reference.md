---
title: API reference
weight: -7
aliases:
  - /docs/api-reference/
---

# API reference

Code: `app/openapi.yaml`, `app/openapi.go`, routes in `app/app.go`

The running API serves its full reference:

- `GET /docs`: interactive reference (Scalar), e.g. `http://localhost:5000/docs`
- `GET /openapi.yaml`: the OpenAPI 3.1 spec, for clients and code generators

Route groups at a glance:

| Prefix | Auth | Guide |
| --- | --- | --- |
| `/healthz`, `/readyz` | none | [Deployment]({{< relref "deployment" >}}) |
| `/auth` | none, rate limited | [Authentication]({{< relref "authentication" >}}) |
| `/invites/accept` | none, rate limited | [Organizations & multi-tenancy]({{< relref "organizations" >}}) |
| `/me`, `/users` | user (`GET /users` and other users' `/users/{id}`: platform admins) | [Authentication]({{< relref "authentication" >}}) |
| `/files` | user | [File uploads]({{< relref "files" >}}) |
| `POST /organizations` | user | [Organizations & multi-tenancy]({{< relref "organizations" >}}) |
| `/organizations/{orgID}` | user or API key, tenant | [Organizations & multi-tenancy]({{< relref "organizations" >}}) |
| `/organizations/{orgID}/billing` | user | [Billing]({{< relref "billing" >}}) |
| `/organizations/{orgID}/webhooks` | user or API key | [Webhooks]({{< relref "webhooks" >}}) |
| `/projects` | user or API key, tenant | [Project structure]({{< relref "project-structure" >}}) |
| `/jobs` | user or API key, tenant | [Jobs]({{< relref "jobs" >}}) |
| `GET /admin/stats` | user with `platform:stats` (platform admins only) | [Platform admin]({{< relref "admin" >}}) |
| `/webhooks/stripe` | Stripe signature | [Billing]({{< relref "billing" >}}) |

## Conventions

- Send `Authorization: Bearer <token>`, and `X-Org-ID` on tenant routes without `{orgID}`.
- Responses are `{"object", "data"}`. Lists add `has_more` and `starting_after` for pagination.
- Authenticated routes are rate limited per API key, else per user, else per IP (`API_RATE_LIMIT`); over the limit you get 429 with `Retry-After`.
- Errors are `{"object": "error", "error": {"type", "message"}}` with a matching HTTP status.
