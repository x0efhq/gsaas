---
title: Deploy to Fly.io
weight: 81
aliases:
  - /docs/how-to/deploy-to-fly/
---

# Deploy to Fly.io

Follow the topology diagram on [Deploy]({{< relref "/docs/deploy/" >}}). Complete that production checklist first. These steps use Postgres.

## Create the app and the database

1. Create the app:

   ```sh
   fly apps create gsaas
   ```

2. Create a Managed Postgres cluster:

   ```sh
   fly mpg create
   ```

3. Attach the cluster to the app. The command sets the `DATABASE_URL` secret:

   ```sh
   fly mpg attach <CLUSTER ID> -a gsaas
   ```

## Set secrets

```sh
fly secrets set --stage -a gsaas \
  JWT_SECRET="$(openssl rand -base64 48)" \
  APP_BASE_URL=https://api.example.com
```

Add the `S3_*` variables and any Stripe or SMTP variables the checklist requires.

## Configure the app

Create `fly.toml`:

```toml
app = "gsaas"
kill_timeout = 15

[build]
  dockerfile = "Dockerfile"

[build.args]
  VERSION = "1.0.0"

[deploy]
  release_command = "/migrate up"

[env]
  APP_ENV = "production"
  TRUST_PROXY = "true"

[processes]
  app = "/server"
  worker = "/worker"

[http_service]
  internal_port = 5000
  force_https = true
  auto_stop_machines = "off"
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

  [[http_service.checks]]
    grace_period = "10s"
    interval = "15s"
    method = "GET"
    timeout = "2s"
    path = "/readyz"
```

## Deploy

1. Deploy:

   ```sh
   fly deploy
   ```

2. Confirm the release command finished in the deploy output.

3. Confirm both process groups are running:

   ```sh
   fly status -a gsaas
   ```

## Add a domain

1. Request a certificate:

   ```sh
   fly certs add api.example.com -a gsaas
   ```

2. Create the DNS records that the command prints.

3. Confirm `https://api.example.com/healthz` returns 200.
