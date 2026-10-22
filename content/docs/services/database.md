---
title: Database & migrations
weight: -10
aliases:
  - /docs/database/
---

# Database & migrations

Code: `database/` (migrations, queries, generated sqlc), `adapters/postgres/`, `cmd/migrate/`

gsaas stores everything in the database. You write plain SQL: schema changes go in migration files, and queries are turned into typed Go functions by sqlc (a code generator), so there is no ORM.

**What you get**

- **Local Postgres in one command.** `make postgres` starts Postgres 16 in Docker Compose.
- **Versioned migrations.** Numbered SQL files, run with goose (a migration tool), with up and down steps.
- **Typed queries.** Each SQL query becomes a Go function; `make check` fails if the generated code is stale.
- **Swappable stores.** Each module talks to an interface; the Postgres code lives only in `adapters/postgres/`.

## Common tasks

| Task | Command |
| --- | --- |
| Start Postgres | `make postgres` |
| Apply pending migrations | `make migrate` |
| Undo the last migration | `make migrate-down` |
| Undo all migrations | `make migrate-down-all` |
| See which migrations ran (read-only) | `make migrate-version` |
| Migrate and add local admin and member users | `make seed` |
| Regenerate Go code after changing queries | `make sqlc-gen` |

Every target except `make sqlc-gen` starts the Postgres container first. `make migrate` also creates the job queue's tables.

## Adding a table and queries

1. Create `database/postgres/migrations/0000N_<name>.sql` with the next number, including `-- +goose Up` and `-- +goose Down`.
2. Add queries to `database/postgres/query/<module>.sql`.
3. Run `make sqlc-gen`.
4. Implement the store method in `adapters/postgres/<module>.go`, and the same method in the module's `mem.go`.
5. Run `make migrate`.

A migration, from `00003_projects.sql`:

```sql
-- +goose Up
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE projects;
```

A query, from `database/postgres/query/projects.sql`. The `-- name:` line sets the Go function name and what it returns (`:one`, `:many`, `:execrows`):

```sql
-- name: ProjectByID :one
SELECT * FROM projects WHERE organization_id = @organization_id AND id = @id;
```

Scope every tenant query by `organization_id`, as above.

## Layout

- `database/postgres/migrations/`: numbered goose migrations, for example `00003_projects.sql`. They are embedded in the binary, so `cmd/migrate` needs no files at runtime.
- `database/postgres/query/`: SQL queries with `-- name:` annotations
- `database/sqlc/`: generated code. Never edit it by hand.
- `adapters/postgres/`: stores that implement each module's `Store` interface

## Transactions

A database store uses the transaction in `ctx` when there is one, so several store calls and job enqueues can share one transaction. Modules that need this add `InTx(ctx, fn)` to their `Store` interface and wrap the calls in it, as `billing` and `organization` do. The store in `adapters/postgres/` implements it with `DB.InTx`.
