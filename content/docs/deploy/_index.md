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

Ship the API and the worker as two processes from the repository image. Apply migrations before the new API serves traffic. Host pages below cover Fly, Render, Railway, and a VPS. They use Postgres. After [the SQLite switch]({{< relref "/docs/operate/use-sqlite.md" >}}), skip `/worker` and keep the database file on a persistent volume.

## Production checklist

Complete this once for any host. Variable names are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}).

1. Set `APP_ENV` to any value other than `local`.
2. Set `JWT_SECRET` to at least 32 random bytes. The server refuses to start without it outside `local`.
3. Set `DATABASE_URL` to the production database.
4. Set `APP_BASE_URL` to the public API origin.
5. Set `STORAGE_SIGNING_KEY` to at least 32 random bytes when you keep disk storage.
6. Set Stripe and SMTP variables for the features you use.
7. Do not set `WEBHOOK_ALLOW_INSECURE`.
8. Put HTTPS in front of the API. When exactly one proxy appends to `X-Forwarded-For`, set `TRUST_PROXY=true` so rate limits see the client address.
9. When the API and the worker do not share a disk, switch file storage to S3 before you deploy. See [How to store files in S3]({{< relref "/docs/files/store-files-in-s3.md" >}}). Disk storage needs one host and a volume both processes mount.
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
