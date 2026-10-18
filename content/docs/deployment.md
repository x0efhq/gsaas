---
title: Deployment
weight: -8
---

# Deployment

Code: `Dockerfile`, `cmd/server/`, `cmd/worker/`

The repository has a multi-stage `Dockerfile`. It builds static binaries and runs them on a distroless, non-root image. The image holds three commands:

- `/server`, the API on port 5000 (the default entrypoint)
- `/worker`, the background job worker
- `/migrate up`, which applies database migrations

```bash
docker build --build-arg VERSION=1.0.0 -t gsaas .
docker run --env-file .env gsaas /migrate up                 # before starting a new version
docker run --env-file .env -p 5000:5000 gsaas                # API
docker run --env-file .env --entrypoint /worker gsaas        # worker
```

`VERSION` is optional; it is compiled in and shown by `/healthz`.

Your deployment needs:

- Postgres, with `DATABASE_URL` pointing to it
- Migrations applied (`/migrate up`, or `go run ./cmd/migrate up`) before starting a new version
- The worker running as a separate process next to the API
- Production settings: `APP_ENV=production` (anything but `local`), your own `JWT_SECRET` (at least 32 random bytes; the server won't start without it), `APP_BASE_URL`, and any Stripe, SMTP and S3 variables you use. See [Configuration]({{< relref "configuration" >}}).
- HTTPS in front of the API. Outside local, responses carry `Strict-Transport-Security`.
- Behind a proxy or load balancer, `TRUST_PROXY=true` so rate limits see real client IPs. Only if the proxy overwrites `X-Forwarded-For` / `X-Real-IP`.

Never set `WEBHOOK_ALLOW_INSECURE` in production.

## Health checks

- `GET /healthz`: the process is up
- `GET /readyz`: the app can reach the database

## Local Docker

`docker-compose.yaml` runs Postgres. With the `app` profile it also builds the image, applies migrations, then starts the API and the worker. Settings come from `.env` if it exists.

```bash
cp .env.example .env
docker compose --profile app up --build   # API on localhost:5000
```
