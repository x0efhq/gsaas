---
title: Deploy
weight: 80
bookCollapseSection: false
aliases:
  - /docs/deployment/
  - /docs/services/deployment/
  - /docs/how-to/deploy/
---

# Deploy

Ship from the repository image. Apply migrations before the new API serves traffic. Host pages below cover Fly, Render, Railway, and a VPS. They use Postgres. After [the SQLite switch]({{< relref "/docs/operate/use-sqlite.md" >}}), skip `/worker` and keep the database file on a persistent volume.

```
           HTTPS proxy
               │
   /migrate up ▼ (pre-deploy)
 ┌──────── /server :5000 ───────┐      ┌── /worker ──┐
 │  /healthz /readyz            │      │  job queue  │
 └──────────────┬───────────────┘      └──────┬──────┘
                └────── Postgres (DATABASE_URL) ┘   + S3 if no shared disk
```

## Production checklist

Complete this once for any host. Variable names are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}).

| Variable | Required value |
| --- | --- |
| `APP_ENV` | any value other than `local` |
| `JWT_SECRET` | at least 32 random bytes |
| `DATABASE_URL` | the production database |
| `APP_BASE_URL` | the public API origin |
| `STORAGE_SIGNING_KEY` | at least 32 random bytes when you keep disk storage |
| Stripe and SMTP | set for the features you use |
| `WEBHOOK_ALLOW_INSECURE` | do not set |

8. Put HTTPS in front of the API. When exactly one proxy appends to `X-Forwarded-For`, set `TRUST_PROXY=true` so rate limits see the client address.
9. When the API and the worker do not share a disk, switch file storage to S3 before you deploy. See [Store files in S3]({{< relref "/docs/files/store-files-in-s3.md" >}}). Disk storage needs one host and a volume both processes mount.
10. Confirm `GET /healthz` and `GET /readyz` after deploy. Health and readiness details are on the [API]({{< relref "/docs/reference/api.md" >}}) page. The worker runs the job queue; the API does not. See [Jobs]({{< relref "/docs/reference/jobs.md" >}}).

## Build and run the image

```bash
docker build --build-arg VERSION=1.0.0 -t gsaas .
docker run --env-file .env gsaas /migrate up
docker run --env-file .env -p 5000:5000 gsaas
docker run --env-file .env gsaas /worker
```

`VERSION` is optional. `/healthz` reports it. `/server` is the image's default command and listens on port 5000.

## Hosts

- [Fly.io]({{< relref "deploy-to-fly" >}})
- [Render]({{< relref "deploy-to-render" >}})
- [Railway]({{< relref "deploy-to-railway" >}})
- [VPS with Docker Compose]({{< relref "deploy-to-a-vps" >}})
