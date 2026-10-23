---
title: How to deploy to a VPS with Docker Compose
weight: 16
---

# How to deploy to a VPS with Docker Compose

Run the database, migrations, API, worker, and a TLS proxy with the repository's `docker-compose.yaml`. For the settings every host needs, see [How to deploy]({{< relref "deploy" >}}).

1. Install Docker Engine and the Compose plugin on the server.
2. Point an `A` record for `api.example.com` at the server.
3. Clone the repository on the server.
4. Create `.env` in the repository root:

   ```sh
   APP_ENV=production
   JWT_SECRET=<at least 32 random bytes>
   STORAGE_SIGNING_KEY=<at least 32 random bytes>
   APP_BASE_URL=https://api.example.com
   TRUST_PROXY=true
   POSTGRES_PASSWORD=<a strong password>
   VERSION=1.0.0
   ```

5. Create `compose.prod.yaml`:

   ```yaml
   services:
     postgres:
       restart: unless-stopped

     app:
       ports: !reset []
       restart: unless-stopped

     worker:
       restart: unless-stopped

     caddy:
       image: caddy:2
       profiles: ["app"]
       command: caddy reverse-proxy --from api.example.com --to app:5000
       ports:
         - "80:80"
         - "443:443"
       volumes:
         - caddy_data:/data
       depends_on:
         - app
       restart: unless-stopped

   volumes:
     caddy_data:
   ```

6. Start the stack. Name both files so Compose skips the local `compose.override.yaml`, which publishes Postgres:

   ```sh
   docker compose -f docker-compose.yaml -f compose.prod.yaml --profile app up -d --build
   ```

7. Confirm the `migrate` container exited with code 0:

   ```sh
   docker compose -f docker-compose.yaml -f compose.prod.yaml ps -a migrate
   ```

8. Confirm `https://api.example.com/readyz` returns 200.

To ship a new version, pull the code, update `VERSION`, and run step 6 again.

Uploaded files stay in the `uploads` volume, which the API and the worker share. Back it up with the database.

Postgres reads `POSTGRES_PASSWORD` only when it creates the `pgdata` volume. An existing volume keeps its old password. To change it, run `ALTER USER app PASSWORD '<new password>';` in the database, then update `.env`.

See [Configuration]({{< relref "configuration" >}}) for every variable.
