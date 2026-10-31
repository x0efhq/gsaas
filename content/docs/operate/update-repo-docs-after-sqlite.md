---
title: Update repository docs after SQLite
weight: 73
bookHidden: true
---

# Update repository docs after SQLite

Maintainer steps for the public template after [How to use SQLite]({{< relref "use-sqlite" >}}). Buyers who already forked can skip this page.

1. In `AGENTS.md`:
   - Under **Done means**, delete the sentences about Postgres tests and `TEST_DATABASE_URL`. Keep the SQLite one.
   - Under **Layout**, drop "The server and worker share that directory." and make the last sentence "The database is SQLite."
   - Reword **A migration + query** to: "Make the change under `database/sqlite`, add `-- name:` queries there, run `make sqlc-gen`, implement the store there, and mirror in `mem.go`. `database/storetest` runs against both."
   - Delete the **SQLite** section.
2. In `README.md`:
   - In the tagline, change `PostgreSQL` to `SQLite`.
   - Under **Architecture**, drop Postgres from the `database/` line, and drop `worker` from the `cmd/` line.
   - Under **Module cross-section**, link `database/sqlite/projects.go` as the SQLite store and `database/sqlite/migrations/00003_projects.sql` as the migration.
   - Under **Quickstart**, drop "and the worker" from the Docker comment, and delete the `compose.override.yaml` paragraph about Postgres on localhost:5432 and `POSTGRES_PASSWORD`. Replace the two Postgres sections with one local section: Go 1.26 (sqlc only to change SQL), then `cp .env.example .env`, `mkdir -p data`, `make seed`, and `make run`. The API runs the jobs, so drop every `go run ./cmd/worker` line.
   - In the env table, describe `DATABASE_URL` as the SQLite file path.
