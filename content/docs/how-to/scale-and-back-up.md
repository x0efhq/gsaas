---
title: How to scale and back up
weight: 8
---

# How to scale and back up

Run more than one API or worker process on Postgres, or keep a single SQLite server. Back up the database and any on-disk uploads.

## Scale on Postgres

The default stack uses Postgres and [River](https://riverqueue.com/) for the job queue. Every API and worker process uses the same `DATABASE_URL`.

Run one or more API processes behind a load balancer. Session access tokens are stateless JWTs, so any API instance can serve a request. Point every instance at the same database.

Run one or more worker processes with `/worker` (or `go run ./cmd/worker`). River stores jobs in Postgres and assigns work across workers. Each worker process runs up to 10 concurrent jobs on the default queue. Stripe webhooks, customer webhook delivery, and other enqueued work need at least one worker running.

`GET /readyz` includes `worker_ok`. It is `false` when no worker has heartbeated within `WORKER_HEARTBEAT_MAX_AGE` (default 90s). The response stays 200.

When API and worker machines do not share a disk, store uploads in S3. See [How to store files in S3]({{< relref "store-files-in-s3" >}}). On a single host you can keep `STORAGE_DIR` on a volume the API and worker both mount, as in [How to deploy to a VPS with Docker Compose]({{< relref "deploy-to-a-vps" >}}).

For the two-process layout and migration order, see [How to deploy]({{< relref "deploy" >}}).

## SQLite limits

After [the SQLite switch]({{< relref "use-sqlite" >}}), one API process owns the database file. SQLite allows one writer at a time, so do not run multiple API replicas or a separate worker against the same file. The API embeds the worker; skip `/worker`.

## Back up Postgres

Take a logical backup of the database the API uses, for example with `pg_dump` against `DATABASE_URL`. Schedule it on the host or with your provider's backup feature. Restore with your provider's procedure or `psql` on a fresh database, then point `DATABASE_URL` at it and run `/migrate up` if the restore is empty.

If uploads stay in `STORAGE_DIR`, copy that directory on the same schedule. If you use S3, rely on the bucket's versioning or replication instead.

## Back up SQLite

Stop the API, or copy the main file and its sidecar files together while traffic is off. SQLite writes `app.db-wal` and `app.db-shm` beside `DATABASE_URL`. Back up all three files as one set. See [How to use SQLite]({{< relref "use-sqlite" >}}).

Copy the `uploads` volume or `STORAGE_DIR` with the database when files are not in S3.
