---
title: Configuration
weight: -19
---

# Configuration

Code: `platform/config/config.go`, `.env.example`

All settings come from environment variables, read in `platform/config/config.go`. Copy `.env.example` to `.env` to start. Every setting has a default, so the server boots with only `DATABASE_URL` set.

| Area | Variables |
| --- | --- |
| Server | `APP_ENV`, `PORT`, `SHUTDOWN_TIMEOUT`, `MAX_BODY_BYTES`, `CORS_ALLOWED_ORIGINS`, `AUTH_RATE_LIMIT`, `TRUST_PROXY` (default false), `APP_BASE_URL`, `APP_NAME` |
| Worker | `WORKER_SHUTDOWN_TIMEOUT` (default 10s) |
| Database | `DATABASE_URL` (required) |
| Local auth | `JWT_SECRET`, `ACCESS_TTL`, `REFRESH_TTL`, `MAGIC_LINK_TTL`, `MAGIC_LINK_HOURLY_LIMIT` (default 5), `INVITE_TTL` |
| Supabase auth | `SUPABASE_URL` |
| Billing | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_PRO`, `STRIPE_PRICE_ITEM` |
| Frontend links | `FRONTEND_BASE_URL`, `MAGIC_LINK_PATH` (default `/auth/magic-link`), `INVITE_ACCEPT_PATH` (default `/invites/accept`), `CHECKOUT_SUCCESS_PATH`, `CHECKOUT_CANCEL_PATH`, `PORTAL_RETURN_PATH` |
| Email | `SMTP_HOST`, `SMTP_PORT`, `SMTP_TLS`, `SMTP_USER`, `SMTP_PASS`, `EMAIL_FROM` |
| File storage | `S3_ENDPOINT`, `S3_REGION`, `S3_PUBLIC_URL`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_PUBLIC_BUCKET`, `S3_PRIVATE_BUCKET`, `FILE_EXPIRES`, `UPLOAD_MAX_BYTES` (default 10 MiB) |
| Outbound webhooks | `WEBHOOK_MAX_ENDPOINTS` (default 20), `WEBHOOK_ALLOW_INSECURE` (local development only) |
| Seed users | `SEED_ADMIN_*`, `SEED_MEMBER_*` (`EMAIL`, `PASSWORD`, `FIRST_NAME`, `LAST_NAME`) |

Optional integrations turn on when you set their variables:

- With no `STRIPE_SECRET_KEY`, the app runs without a billing processor.
- With no `SMTP_HOST`, emails are written to the log rather than sent.
- With no `S3_ACCESS_KEY_ID` or `S3_ENDPOINT`, no file storage is configured.

Outside local development (`APP_ENV` other than `local`):

- The server refuses to start unless `JWT_SECRET` is set to a random value of at least 32 bytes, for example `openssl rand -hex 32`. The built-in default is for local use only.
- Responses carry `Strict-Transport-Security`, so serve the API over HTTPS.

`TRUST_PROXY=true` takes the client IP, used for rate limits and logs, from the `X-Real-IP` or `X-Forwarded-For` header. Set it only behind a proxy or load balancer that overwrites those headers; otherwise clients can fake their IP and get around rate limits.

`FRONTEND_BASE_URL` is where emailed sign-in and invite links and Stripe redirects land; empty uses `APP_BASE_URL`. See [Emailed links]({{< relref "authentication#emailed-links" >}}).

`WORKER_SHUTDOWN_TIMEOUT` is how long a stopping worker lets running jobs finish.

Settings that fail validation stop startup with an error naming the variable.

To add a setting, add a field with a default to `Config` in `platform/config/config.go`.
