---
title: How to add a migration
weight: 9
aliases:
  - /docs/database/
  - /docs/services/database/
---

# How to add a migration

Add a table for a new module, or change an existing table, with a numbered SQL file. Queries stay in SQL. sqlc generates the Go.

1. Add `database/postgres/migrations/0000N_<name>.sql` with the next number. Include `-- +goose Up` and `-- +goose Down`. Change an existing table by editing its migration only when that migration has not shipped. A shipped change is a new file.
2. Add queries to `database/postgres/query/<module>.sql`. The `-- name:` line is the Go function name. `:one`, `:many`, or `:execrows` is what it returns. A tenant query includes `organization_id` in the `WHERE` clause.
3. Run `make sqlc-gen`. Do not edit `database/sqlc/`.
4. Implement the store method in `adapters/postgres/<module>.go` and the same method on the in-memory store in the module's `mem.go`.
5. Run `make migrate`.

`make check` fails when `database/sqlc` does not match the queries.
