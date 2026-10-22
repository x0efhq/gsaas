---
title: How to deploy
weight: 7
aliases:
  - /docs/deployment/
  - /docs/services/deployment/
---

# How to deploy

Ship the API and the worker as two processes from the image in the repository. Apply migrations before the new API starts serving.

Set production values in the environment you pass to the containers:

- `APP_ENV` to any value other than `local`
- `JWT_SECRET` to at least 32 random bytes (the server refuses to start without it)
- `DATABASE_URL` to the production database
- `APP_BASE_URL` to the public API origin
- Stripe, SMTP, and S3 variables for the features you use

Do not set `WEBHOOK_ALLOW_INSECURE`.

Build and run:

```bash
docker build --build-arg VERSION=1.0.0 -t gsaas .
docker run --env-file .env gsaas /migrate up
docker run --env-file .env -p 5000:5000 gsaas
docker run --env-file .env gsaas /worker
```

`VERSION` is optional. `/healthz` reports it. `/server` is the image's default command and listens on port 5000.

Put HTTPS in front of the API. When exactly one proxy appends to `X-Forwarded-For`, set `TRUST_PROXY=true` so rate limits see the client address.

`GET /healthz` returns 200 when the process is up. `GET /readyz` returns 200 when the process can reach the database.

Variable names are on the [Configuration]({{< relref "configuration" >}}) page.
