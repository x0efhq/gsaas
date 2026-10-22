---
title: How to deploy to Fly.io
weight: 13
---

# How to deploy to Fly.io

Run the API and the worker as two Fly apps built from the same Dockerfile. For the settings every host needs, see [How to deploy]({{< relref "deploy" >}}).

The image's entrypoint is `/server`. Fly process groups and `release_command` replace only `CMD`, so this guide overrides the entrypoint instead.

## Create the apps and the database

1. Create the API app and the worker app:

   ```sh
   fly apps create gsaas-api
   fly apps create gsaas-worker
   ```

2. Create a Managed Postgres cluster:

   ```sh
   fly mpg create
   ```

3. Attach the cluster to both apps. Each command sets the `DATABASE_URL` secret:

   ```sh
   fly mpg attach <CLUSTER ID> -a gsaas-api
   fly mpg attach <CLUSTER ID> -a gsaas-worker
   ```

## Set secrets

1. Set the secrets on the API app:

   ```sh
   fly secrets set --stage -a gsaas-api \
     JWT_SECRET="$(openssl rand -base64 48)" \
     APP_BASE_URL=https://api.example.com
   ```

2. Set the same `JWT_SECRET`, `APP_BASE_URL`, and any Stripe, SMTP, or storage variables on the worker app with `fly secrets set --stage -a gsaas-worker`.

## Configure the API app

Create `fly.toml`:

```toml
app = "gsaas-api"
kill_timeout = 15

[build]
  dockerfile = "Dockerfile"

[build.args]
  VERSION = "1.0.0"

[env]
  APP_ENV = "production"
  TRUST_PROXY = "true"

[http_service]
  internal_port = 5000
  force_https = true
  auto_stop_machines = "off"
  auto_start_machines = true
  min_machines_running = 1

  [[http_service.checks]]
    grace_period = "10s"
    interval = "15s"
    method = "GET"
    timeout = "2s"
    path = "/readyz"
```

## Configure the worker app

Create `fly.worker.toml`:

```toml
app = "gsaas-worker"
kill_timeout = 15

[build]
  dockerfile = "Dockerfile"

[build.args]
  VERSION = "1.0.0"

[env]
  APP_ENV = "production"

[experimental]
  entrypoint = ["/worker"]
```

## Deploy

1. Build and push the API image without deploying it:

   ```sh
   fly deploy --build-only --push --image-label v1.0.0
   ```

2. Run the migrations in a one-off Machine:

   ```sh
   fly machine run registry.fly.io/gsaas-api:v1.0.0 up \
     --entrypoint /migrate --rm -a gsaas-api
   ```

3. Confirm the Machine exited with code 0 in `fly logs -a gsaas-api`.

4. Deploy the API:

   ```sh
   fly deploy --image registry.fly.io/gsaas-api:v1.0.0
   ```

5. Deploy the worker:

   ```sh
   fly deploy -c fly.worker.toml
   ```

## Add a domain

1. Request a certificate:

   ```sh
   fly certs add api.example.com -a gsaas-api
   ```

2. Create the DNS records that the command prints.

3. Confirm `https://api.example.com/healthz` returns 200.

See [Configuration]({{< relref "configuration" >}}) for every variable.
