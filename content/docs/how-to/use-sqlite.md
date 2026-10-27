---
title: How to use SQLite
weight: 12
---

# How to use SQLite

Run gsaas on one SQLite file instead of Postgres. Use one database. Rows are not copied between them.

Keep Postgres when you run more than one API instance, when the host has no persistent disk, or when you use a managed database. Fly.io, Render, and Railway deploys in these docs use Postgres.

Use SQLite for one server with a persistent disk, such as a small VPS. SQLite allows one writer at a time, so one process owns the file. The API runs the background worker itself, and you do not run `/worker`. The job queue's SQLite driver is experimental in River, the queue library.

Switching is a code change, not a setting. `adapters/sqlite` and `database/sqlite` are already in the repository. You point `app.New` at them, then delete the Postgres code.

## Change the code

1. In `app.New` in `app/app.go`, find the block that starts with the `// Postgres.` comment and ends at `adminStore`. In that block, change every `postgres.` to `sqlite.` and `river.NewPostgres` to `river.NewSQLite`:

   ```go
   db, err := sqlite.Open(ctx, cfg.DatabaseURL)
   // ...
   jobQueue, err := river.NewSQLite(db.SQL, sqlite.TxFrom, cfg.WorkerShutdownTimeout)
   // ...
   billingStore := sqlite.NewBillingStore(db)
   ```

   Import `gsaas/adapters/sqlite` instead of `gsaas/adapters/postgres`, delete the comment, and run `gofmt -w app/app.go`.

2. In `cmd/server/main.go`, start the worker after the line `go func() { errc <- srv.Serve(ln) }()`:

   ```go
   workerDone := make(chan error, 1)
   go func() { workerDone <- application.RunWorker(ctx); stop() }()
   ```

3. In the same file, call `stop()` on the line after the `select` block. Then change the shutdown line so running jobs finish before the database closes:

   ```go
   err = errors.Join(srv.Shutdown(shut), <-workerDone, application.Close(shut))
   ```

4. Delete `cmd/worker`.

5. In `cmd/migrate/main.go`, change `postgres.Open` and `postgres.Migrate` to `sqlite.Open` and `sqlite.Migrate`. Import `gsaas/database/sqlite/migrations` instead of `gsaas/database/postgres/migrations`, and change `goose.SetDialect("postgres")` to `goose.SetDialect("sqlite3")`.

6. Delete the Postgres code:
   - `adapters/postgres` and `database/postgres`
   - the `engine: postgresql` entry in `sqlc.yaml`
   - `adapters/river/postgres.go` and `adapters/river/postgres_test.go`
   - `adapters/stripe/apply_test.go`, a Postgres-only test

   In the package comment at the top of `adapters/river/river.go`, delete the sentence about `postgres.go` and `sqlite.go`.

7. Run `go mod tidy`, then `make check`.

`AGENTS.md` in the repository has the same checklist in its SQLite section.

## Set the database path

`DATABASE_URL` holds a file path, not a URL. The directory must exist. SQLite creates the file. In `.env.example`, use the commented SQLite line and drop `POSTGRES_PASSWORD` and `TEST_DATABASE_URL` with their comments. Under `STORAGE_DIR`, drop the line that says the server and worker must share the directory:

```sh
DATABASE_URL=data/app.db
```

To run locally, copy `.env.example` to `.env`, or set the same `DATABASE_URL` in the `.env` you already have. Create `data/` before `make migrate`, `make run`, or `make seed`:

```sh
cp .env.example .env
mkdir -p data
```

SQLite also writes `app.db-wal` and `app.db-shm` beside the file. Back up all three together, or stop the API first.

## Change the tooling

1. In the `Makefile`, delete the `postgres` target and remove it from the targets that depend on it.
2. Delete `compose.override.yaml`. It only publishes Postgres.
3. In `docker-compose.yaml`, delete the `postgres` and `worker` services, the `pgdata` volume, every `depends_on` entry for `postgres`, and the comment `# The server and worker share this upload directory.` Set `DATABASE_URL: /data/db/app.db`, and mount a `db:/data/db` volume next to `uploads`.
4. In the `Dockerfile`:
   - Remove `worker` from the `for cmd in server worker migrate` build loop and from `COPY --from=build /server /worker /migrate /`. With `cmd/worker` deleted, the image build fails otherwise.
   - Change the comment to `# One image, two commands: /server (default), /migrate up.`
   - Create `/out/data/db` next to `/out/data/uploads`, so the mounted volume is writable.
5. In `.github/workflows/check.yml`, delete the `postgres` service, the `env` block with `TEST_DATABASE_URL` and its comment, and the "Migrate the test database" step. The SQLite store tests run on a temporary file every time.

## Update the repository docs

1. In `AGENTS.md`:
   - Under **Done means**, delete the sentences about Postgres tests and `TEST_DATABASE_URL`. Keep the SQLite one.
   - Under **Layout**, drop "The server and worker share that directory." and make the last sentence "The database is SQLite."
   - Reword **A migration + query** to: "Make the change under `database/sqlite`, add `-- name:` queries there, run `make sqlc-gen`, implement in `adapters/sqlite`, and mirror in `mem.go`. `adapters/storetest` runs against both."
   - Delete the **SQLite** section.
2. In `README.md`:
   - In the tagline, change `PostgreSQL` to `SQLite`.
   - Under **Architecture**, change Postgres to SQLite in the `adapters/` line, and drop `worker` from the `cmd/` line.
   - Under **Module cross-section**, link `adapters/sqlite/projects.go` as the SQLite store and `database/sqlite/migrations/00003_projects.sql` as the migration.
   - Under **Quickstart**, drop "and the worker" from the Docker comment, and delete the `compose.override.yaml` paragraph about Postgres on localhost:5432 and `POSTGRES_PASSWORD`. Replace the two Postgres sections with one local section: Go 1.26 (sqlc only to change SQL), then `cp .env.example .env`, `mkdir -p data`, `make seed`, and `make run`. The API runs the jobs, so drop every `go run ./cmd/worker` line.
   - In the env table, describe `DATABASE_URL` as the SQLite file path.

## Check the switch

Create `.env` and the directory, then apply the migrations and start the API:

```sh
cp .env.example .env
mkdir -p data
go run ./cmd/migrate up
go run ./cmd/server
```

`GET /readyz` returns 200. Create a project with `POST /projects`, then call `GET /jobs`. The `projects.apply` job shows `"status": "succeeded"` without a separate worker running.
