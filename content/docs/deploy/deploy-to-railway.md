---
title: How to deploy to Railway
weight: 83
aliases:
  - /docs/how-to/deploy-to-railway/
---

# How to deploy to Railway

Run the API and the worker as two Railway services built from the same repository. Complete the [Deploy]({{< relref "/docs/deploy/" >}}) production checklist first. These steps use Postgres.

## Add the database

1. In your project, click **+ New** > **Database** > **PostgreSQL**.
2. Confirm the service is named `Postgres`.

## Create the API service

1. Click **+ New** > **GitHub Repo** and select the repository. Name the service `api`.
2. In **Variables**, add:

   ```text
   APP_ENV=production
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   JWT_SECRET=<at least 32 random bytes>
   APP_BASE_URL=https://api.example.com
   TRUST_PROXY=true
   VERSION=1.0.0
   ```

3. In **Settings** > **Deploy**, set **Pre-deploy Command** to `/migrate up`.
4. Set **Healthcheck Path** to `/readyz`.
5. Leave **Start Command** empty.
6. Deploy the service.

## Create the worker service

1. Click **+ New** > **GitHub Repo** and select the same repository. Name the service `worker`.
2. In **Variables**, add:

   ```text
   APP_ENV=production
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   JWT_SECRET=${{api.JWT_SECRET}}
   APP_BASE_URL=${{api.APP_BASE_URL}}
   ```

3. In **Settings** > **Deploy**, set **Start Command** to `/worker`.
4. Deploy the service.

Add the `S3_*` variables and any Stripe or SMTP variables to both services.

## Add a domain

1. In the `api` service, open **Settings** > **Networking** and add `api.example.com` as a custom domain.
2. Create the DNS records that Railway shows.
3. Confirm `https://api.example.com/healthz` returns 200.
