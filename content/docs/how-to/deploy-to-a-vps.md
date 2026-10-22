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
   APP_BASE_URL=https://api.example.com
   TRUST_PROXY=true
   VERSION=1.0.0
   ```

5. Create `compose.override.yaml`:

   ```yaml
   services:
     postgres:
       ports: !reset []
       environment:
         POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?}
       restart: unless-stopped

     app:
       ports: !reset []
       environment:
         DATABASE_URL: postgres://app:${POSTGRES_PASSWORD:?}@postgres:5432/app?sslmode=disable
       restart: unless-stopped

     worker:
       environment:
         DATABASE_URL: postgres://app:${POSTGRES_PASSWORD:?}@postgres:5432/app?sslmode=disable
       restart: unless-stopped

     migrate:
       environment:
         DATABASE_URL: postgres://app:${POSTGRES_PASSWORD:?}@postgres:5432/app?sslmode=disable

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

6. Add `POSTGRES_PASSWORD=<a strong password>` to `.env`.
7. Start the stack:

   ```sh
   docker compose --profile app up -d --build
   ```

8. Confirm the `migrate` container exited with code 0:

   ```sh
   docker compose ps -a migrate
   ```

9. Confirm `https://api.example.com/readyz` returns 200.

To ship a new version, pull the code, update `VERSION`, and run step 7 again.

See [Configuration]({{< relref "configuration" >}}) for every variable.
