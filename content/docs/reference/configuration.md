---
title: Configuration
weight: 92
aliases:
  - /docs/configuration/
  - /docs/services/configuration/
---

# Configuration

Settings are environment variables, read by `platform/config/config.go`. A variable omitted from the environment uses the default in that file. The server starts with only `DATABASE_URL` set. A value that fails validation stops startup and names the variable.

`TEST_DATABASE_URL` is not an application setting. `go test` reads it. The server does not.

## Server

| Variable | Default | Meaning |
| --- | --- | --- |
| `APP_ENV` | `local` | Any value other than `local` enables the production checks below |
| `PORT` | `5000` | Listen port |
| `LOG_LEVEL` | `info` | Lowest level logged: `debug`, `info`, `warn` or `error` |
| `APP_BASE_URL` | `http://localhost:5000` | Public origin of this API |
| `APP_NAME` | `Boilerplate` | Name used in email |
| `SHUTDOWN_TIMEOUT` | `10s` | How long a stopping server waits for requests |
| `MAX_BODY_BYTES` | 1 MiB | Largest accepted request body |
| `CORS_ALLOWED_ORIGINS` | empty | Allowed browser origins. Empty sends no CORS headers |
| `API_RATE_LIMIT` | `300` | Authenticated requests per minute |
| `AUTH_RATE_LIMIT` | `10` | Public auth requests per minute per IP |
| `TRUST_PROXY` | `false` | When `true`, the client IP is the right-most `X-Forwarded-For` entry |
| `OTLP_ENDPOINT` | empty | OTLP/HTTP base URL for traces and metrics. Empty disables export |

`TRUST_PROXY` and `WEBHOOK_ALLOW_INSECURE` take `true` or `false` (also `1`, `0`, `TRUE`, `FALSE`). Any other value stops startup.

## Database

| Variable | Default | Meaning |
| --- | --- | --- |
| `DATABASE_URL` | | Postgres URL, or a SQLite file path after [the SQLite switch]({{< relref "/docs/operate/use-sqlite.md" >}}). Required |

## Auth

| Variable | Default | Meaning |
| --- | --- | --- |
| `JWT_SECRET` | `local-dev-jwt-secret` | Signs session access tokens. The default is for `APP_ENV=local` only |
| `ACCESS_TTL` | `15m` | Access token lifetime |
| `REFRESH_TTL` | `168h` | Refresh token lifetime |
| `MAGIC_LINK_TTL` | `15m` | Magic-link lifetime |
| `MAGIC_LINK_HOURLY_LIMIT` | `5` | Magic-link requests recorded per address per hour |
| `INVITE_TTL` | `168h` | Invite lifetime |
| `OAUTH_CALLBACK_PATH` | `/auth/oauth/callback` | Frontend path that receives `?code=` after OAuth |
| `GOOGLE_CLIENT_ID` | empty | Google OAuth client id. Empty disables Google (`503` on start) |
| `GOOGLE_CLIENT_SECRET` | empty | Google OAuth client secret |
| `GITHUB_CLIENT_ID` | empty | GitHub OAuth client id. Empty disables GitHub (`503` on start) |
| `GITHUB_CLIENT_SECRET` | empty | GitHub OAuth client secret |

Outside `APP_ENV=local`, startup fails unless `JWT_SECRET` is at least 32 random bytes. Responses then include `Strict-Transport-Security`.

## Billing

| Variable | Default | Meaning |
| --- | --- | --- |
| `STRIPE_SECRET_KEY` | empty | Empty disables the billing processor. Billing routes return 503 |
| `STRIPE_WEBHOOK_SECRET` | | Stripe signing secret. Unsigned events are rejected |
| `STRIPE_PRICE_PRO` | | Recurring price id for plan `pro` |
| `STRIPE_PRICE_ITEM` | empty | One-time price id for plan `item` |

## Links

An empty `FRONTEND_BASE_URL` means links use `APP_BASE_URL`.

| Variable | Default |
| --- | --- |
| `FRONTEND_BASE_URL` | empty, then `APP_BASE_URL` |
| `MAGIC_LINK_PATH` | `/auth/magic-link` |
| `INVITE_ACCEPT_PATH` | `/invites/accept` |
| `CHECKOUT_SUCCESS_PATH` | `/billing/success?session_id={CHECKOUT_SESSION_ID}` |
| `CHECKOUT_CANCEL_PATH` | `/billing/cancel` |
| `PORTAL_RETURN_PATH` | `/billing` |

## Email

| Variable | Default | Meaning |
| --- | --- | --- |
| `SMTP_HOST` | empty | Empty writes messages to the server log |
| `SMTP_PORT` | `587` | |
| `SMTP_TLS` | `starttls` | `starttls`, `tls`, or `none` |
| `SMTP_USER` | empty | |
| `SMTP_PASS` | empty | |
| `EMAIL_FROM` | `Boilerplate <no-reply@localhost>` | From address |

## Files

| Variable | Default | Meaning |
| --- | --- | --- |
| `STORAGE_DIR` | `./data/uploads` | Root directory for stored files. The image sets `/data/uploads` |
| `STORAGE_SIGNING_KEY` | `local-dev-storage-signing-key` | Signs upload and download URLs. The default is for `APP_ENV=local` only |
| `FILE_EXPIRES` | `15m` | Lifetime of a signed upload or download URL |
| `UPLOAD_MAX_BYTES` | 10 MiB | Largest upload |

Files live in `STORAGE_DIR` under `public/` and `private/`. The API serves them at `/storage/{visibility}/{key}`. Upload and private download URLs carry `exp` and `sig`. Public files need no signature. Outside `APP_ENV=local`, startup fails unless `STORAGE_SIGNING_KEY` is at least 32 random bytes. The API and the worker must share `STORAGE_DIR`. Production shared-disk and S3 rules are on the [Deploy]({{< relref "/docs/deploy/" >}}) checklist.

S3 has no settings until you switch the code. See [Store files in S3]({{< relref "/docs/files/store-files-in-s3.md" >}}).

## Webhooks and worker

| Variable | Default | Meaning |
| --- | --- | --- |
| `WEBHOOK_MAX_ENDPOINTS` | `20` | Endpoints one organization may register |
| `WEBHOOK_ALLOW_INSECURE` | `false` | When `true`, customer endpoints may use HTTP. Local only |
| `WORKER_SHUTDOWN_TIMEOUT` | `10s` | How long a stopping worker waits for a job |
| `WORKER_HEARTBEAT_MAX_AGE` | `90s` | `/readyz` sets `worker_ok` false when the worker last heartbeat is older than this |

## Seed

`SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `SEED_ADMIN_FIRST_NAME`, `SEED_ADMIN_LAST_NAME`, and the same four names with the `SEED_MEMBER_` prefix. `cmd/seed` reads them. The server does not.
