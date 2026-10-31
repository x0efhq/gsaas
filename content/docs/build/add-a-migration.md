---
title: Add a migration
weight: 23
aliases:
  - /docs/database/
  - /docs/services/database/
  - /docs/how-to/add-a-migration/
---

# Add a migration

Add a table for a new module, or change an existing table, with a numbered SQL file. Queries stay in SQL. sqlc generates the Go. The repository keeps a Postgres and a SQLite copy of each file. Make each change in both, or only in the one your project kept.

| Piece | Postgres | SQLite |
| --- | --- | --- |
| Migrations | `database/postgres/migrations/` | `database/sqlite/migrations/` |
| Queries | `database/postgres/query/` | `database/sqlite/query/` |
| Store | `database/postgres/<module>.go` | `database/sqlite/<module>.go` |
| Generated | `database/postgres/sqlc/` | `database/sqlite/sqlc/` |

1. Add `database/postgres/migrations/0000N_<name>.sql` and `database/sqlite/migrations/0000N_<name>.sql` with the next number. Include `-- +goose Up` and `-- +goose Down`. Change an existing table by editing its migration only when that migration has not shipped. A shipped change is a new file.

```sql
-- database/postgres/migrations/00003_projects.sql
-- +goose Up
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX projects_organization_id_id_idx ON projects (organization_id, id);

-- +goose Down
DROP TABLE projects;
```

2. Add queries to `database/postgres/query/<module>.sql` and `database/sqlite/query/<module>.sql`. The `-- name:` line is the Go function name. `:one`, `:many`, or `:execrows` is what it returns. A tenant query includes `organization_id` in the `WHERE` clause.

```sql
-- database/postgres/query/projects.sql
-- name: ProjectByID :one
SELECT * FROM projects WHERE organization_id = @organization_id AND id = @id;
```

3. Run `make sqlc-gen`. Do not edit `database/postgres/sqlc/` or `database/sqlite/sqlc/`.
4. Implement the store method in `database/postgres/<module>.go` and `database/sqlite/<module>.go`, and the same method on the in-memory store in the module's `mem.go`.
5. Run `make migrate`.

`make check` fails when the generated sqlc code does not match the queries. See [Run the tests]({{< relref "run-the-tests" >}}). The shared tests in `database/storetest` run against both stores and the in-memory one.
