---
title: Configuration
weight: 2
---

# Configuration

Settings are environment variables, read by `platform/config/config.go`. A variable omitted from the environment uses the default in that file. The server starts with only `DATABASE_URL` set. A value that fails validation stops startup and names the variable.

`TEST_DATABASE_URL` is not an application setting. `go test` reads it. The server does not.

## Server

| Variable | Default | Meaning |
| --- | --- | --- |
| `APP_ENV` | `local` | Any value other than `local` enables the production checks below |
| `PORT` | `5000` | Listen port |
| `APP_BASE_URL` | `http://localhost:5000` | Public origin of this API |
| `APP_NAME` | `Boilerplate` | Name used in email |
| `SHUTDOWN_TIMEOUT` | `10s` | How long a stopping server waits for requests |
| `MAX_BODY_BYTES` | 1 MiB | Largest accepted request body |
| `CORS_ALLOWED_ORIGINS` | empty | Allowed browser origins. Empty sends no CORS headers |
| `API_RATE_LIMIT` | `300` | Authenticated requests per minute |
| `AUTH_RATE_LIMIT` | `10` | Public auth requests per minute per IP |
| `TRUST_PROXY` | `false` | When `true`, the client IP is the right-most `X-Forwarded-For` entry |

Set `TRUST_PROXY` only when one proxy appends that header. Further-left entries are ignored.

## Database

| Variable | Default | Meaning |
| --- | --- | --- |
| `DATABASE_URL` | | Postgres URL. Required |

## Auth

| Variable | Default | Meaning |
| --- | --- | --- |
| `JWT_SECRET` | `local-dev-jwt-secret` | Signs session access tokens. The default is for `APP_ENV=local` only |
| `ACCESS_TTL` | `15m` | Access token lifetime |
| `REFRESH_TTL` | `168h` | Refresh token lifetime |
| `MAGIC_LINK_TTL` | `15m` | Magic-link lifetime |
| `MAGIC_LINK_HOURLY_LIMIT` | `5` | Magic-link requests recorded per address per hour |
| `INVITE_TTL` | `168h` | Invite lifetime |
| `SUPABASE_URL` | empty | When set, the process can verify Supabase tokens. Local auth stays mounted until the verifier in `app.New` is swapped |

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
| `S3_ENDPOINT` | empty | Empty uses AWS. Set it for another S3-compatible store |
| `S3_REGION` | empty | |
| `S3_PUBLIC_URL` | empty | Base for public links. Empty builds AWS links |
| `S3_ACCESS_KEY_ID` | empty | Empty leaves file storage unconfigured |
| `S3_SECRET_ACCESS_KEY` | empty | |
| `S3_PUBLIC_BUCKET` | `public` | |
| `S3_PRIVATE_BUCKET` | `private` | |
| `FILE_EXPIRES` | `15m` | Lifetime of a signed download URL |
| `UPLOAD_MAX_BYTES` | 10 MiB | Largest upload |

## Webhooks and worker

| Variable | Default | Meaning |
| --- | --- | --- |
| `WEBHOOK_MAX_ENDPOINTS` | `20` | Endpoints one organization may register |
| `WEBHOOK_ALLOW_INSECURE` | `false` | When `true`, customer endpoints may use HTTP. Local only |
| `WORKER_SHUTDOWN_TIMEOUT` | `10s` | How long a stopping worker waits for a job |

## Seed

`SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `SEED_ADMIN_FIRST_NAME`, `SEED_ADMIN_LAST_NAME`, and the same four names with the `SEED_MEMBER_` prefix. `cmd/seed` reads them. The server does not.
