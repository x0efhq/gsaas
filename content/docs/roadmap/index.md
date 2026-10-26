---
title: Roadmap
weight: 10
aliases:
  - /docs/services/roadmap/
---

# Roadmap

What's planned for gsaas next. Plans can change, and items aren't promised dates.

**Getting updates:** new releases are pulled from the private repository with git.

## Coming soon

- **Metrics:** a Prometheus `/metrics` endpoint, Stripe webhook metrics, and optional OpenTelemetry tracing.
- **OAuth sign-in** with Google and GitHub.
- **Security:** lockout after repeated failed passwords, an audit log of sign-ins and role and subscription changes, and structured validation errors.
- **Email from background jobs**, so a mail outage never fails a request.
- **Analytics:** request IDs on tracked events, and an HTTP analytics sink.
- **Ops:** build version in logs, optional migrate-on-start for non-production environments, and a Stripe event replay command.
- **Developer experience:** `make domain` to scaffold a new module, live reload, and integration tests.

## Later: CLI builder

Generate a project with only the parts you want:

- **Audience:** B2B, B2C, or both.
- **Database:** local Postgres, Supabase Postgres, or SQLite.
- **Email:** SMTP, Postmark, or Resend.
- **Jobs:** the River job queue on Postgres or SQLite.
- **Files:** local, S3, Cloudflare R2, or Supabase Storage.
- **Auth:** built-in or Supabase.
