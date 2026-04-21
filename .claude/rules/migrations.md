# Migration Rules

Applies to: `db/migrate/`

## Strong Migrations

`strong_migrations` is enabled and blocks unsafe operations. When blocked:

1. Read the error message — it tells you the safe alternative
2. Use the suggested safe migration pattern
3. Only use `safety_assured { }` when you have verified the operation is safe for production data

## Common Safe Patterns

- **Adding a column:** Safe by default (no lock)
- **Adding an index:** Use `algorithm: :concurrently` (wrap in `disable_ddl_transaction!`)
- **Removing a column:** First deploy ignoring the column (`ignored_columns`), then remove
- **Renaming a column:** Add new column, backfill, update code, remove old column
- **Adding a NOT NULL constraint:** Add check constraint first, then validate separately

## Anti-Patterns

- Never use `change_column_null` without `safety_assured` and a separate validation step
- Never add a column with a default on a large table in a single migration step — use a two-step process (add column, then backfill)

## Conventions

- One structural change per migration
- Use reversible migrations when possible
- Include `safety_assured` justification in a code comment when used
