---
title: Scale and back up the database
weight: 74
aliases:
  - /docs/how-to/scale-and-back-up/
---

# Scale and back up the database

Run more than one API or worker process on Postgres, or keep a single SQLite server. Back up the database and any on-disk uploads.

| Concern | Postgres | SQLite |
| --- | --- | --- |
| Processes | One or more API instances behind a load balancer; one or more `/worker` processes | One API process owns the file |
| Writers | Many concurrent writers | One writer at a time |
| Worker | Separate `/worker` (or `go run ./cmd/worker`); River assigns work across workers | API embeds the worker; skip `/worker` |
| Backup | `pg_dump` against `DATABASE_URL`, or the provider's backup | Stop the API, then copy the db file plus `-wal` and `-shm` |

Session access tokens are stateless JWTs, so any Postgres API instance can serve a request. Point every instance at the same `DATABASE_URL`. Each worker process runs up to 10 concurrent jobs on the default queue. Stripe webhooks, customer webhook delivery, and other enqueued work need at least one worker running. See [Jobs]({{< relref "/docs/reference/jobs.md" >}}).

`GET /readyz` includes `worker_ok`. Details are on the [API]({{< relref "/docs/reference/api.md" >}}) page.

When API and worker machines do not share a disk, store uploads in S3. See [Store files in S3]({{< relref "/docs/files/store-files-in-s3.md" >}}). On a single host you can keep `STORAGE_DIR` on a volume the API and worker both mount, as in [Deploy to a VPS with Docker Compose]({{< relref "/docs/deploy/deploy-to-a-vps.md" >}}).

For the two-process layout and the production checklist, see [Deploy]({{< relref "/docs/deploy/" >}}). After [the SQLite switch]({{< relref "use-sqlite" >}}), do not run multiple API replicas or a separate worker against the same file.

## Back up Postgres

```bash
pg_dump "$DATABASE_URL" > backup.sql
```

Schedule it on the host or with your provider's backup feature. Restore with your provider's procedure or `psql` into a fresh database, then point `DATABASE_URL` at it.

If uploads stay in `STORAGE_DIR`, copy that directory on the same schedule. If you use S3, rely on the bucket's versioning or replication instead.

## Back up SQLite

Stop the API before you copy the database. SQLite runs in WAL mode, so it writes `app.db-wal` and `app.db-shm` beside the file in `DATABASE_URL`. Copy all three files together, or use the backup API:

```bash
sqlite3 "$DATABASE_URL" ".backup 'backup.db'"
```

See [Use SQLite]({{< relref "use-sqlite" >}}).

Copy the `uploads` volume or `STORAGE_DIR` with the database when files are not in S3.
