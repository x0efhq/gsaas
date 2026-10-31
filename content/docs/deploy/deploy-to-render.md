---
title: How to deploy to Render
weight: 82
aliases:
  - /docs/how-to/deploy-to-render/
---

# How to deploy to Render

Define the API, the worker, and the database in one Blueprint. Complete the [Deploy]({{< relref "/docs/deploy/" >}}) production checklist first. These steps use Postgres.

1. Create `render.yaml` in the repository root:

   ```yaml
   databases:
     - name: gsaas-db
       plan: basic-256mb
       postgresMajorVersion: "16"
       databaseName: app
       user: app
       ipAllowList: []

   envVarGroups:
     - name: gsaas-shared
       envVars:
         - key: APP_ENV
           value: production
         - key: JWT_SECRET
           generateValue: true

   services:
     - type: web
       name: gsaas-api
       runtime: docker
       dockerfilePath: ./Dockerfile
       preDeployCommand: /migrate up
       healthCheckPath: /readyz
       maxShutdownDelaySeconds: 15
       domains:
         - api.example.com
       envVars:
         - fromGroup: gsaas-shared
         - key: APP_BASE_URL
           sync: false
         - key: TRUST_PROXY
           value: "true"
         - key: VERSION
           value: 1.0.0
         - key: DATABASE_URL
           fromDatabase:
             name: gsaas-db
             property: connectionString

     - type: worker
       name: gsaas-worker
       runtime: docker
       dockerfilePath: ./Dockerfile
       dockerCommand: /worker
       maxShutdownDelaySeconds: 15
       envVars:
         - fromGroup: gsaas-shared
         - key: APP_BASE_URL
           sync: false
         - key: DATABASE_URL
           fromDatabase:
             name: gsaas-db
             property: connectionString
   ```

2. Commit and push `render.yaml`.

3. In the Render Dashboard, click **New** > **Blueprint** and select the repository.

4. Enter `APP_BASE_URL` when Render prompts for it. Add the `S3_*` variables and any Stripe or SMTP variables to the `gsaas-shared` group.

5. Click **Deploy Blueprint**.

6. Confirm the pre-deploy log shows the migrations applied.

7. Create the DNS records that Render lists for `api.example.com`.

8. Confirm `https://api.example.com/healthz` returns 200.

Render passes the `VERSION` variable to the build as a build argument.
