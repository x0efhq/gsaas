---
title: Roadmap
weight: 100
aliases:
  - /docs/services/roadmap/
---

# Roadmap

What is planned for gsaas next. Plans can change. Items are not promised dates.

New releases come from the private repository with git.

## Shipped

- **OAuth sign-in** with Google and GitHub (PKCE, one-time code exchange).
- **Audit log** for org-scoped security and billing actions (`GET /organizations/{orgID}/audit-logs`).
- **OpenTelemetry** export over OTLP/HTTP when `OTLP_ENDPOINT` is set.
- **API key** optional `expires_at` on create.
- **Worker health** in `GET /readyz` (`worker_ok` when the heartbeat is stale).
- **Webhook events** `org.member.removed`, `org.member.role.changed`, and `subscription.changed`.
- **Email from background jobs** (`email.send`), so a mail outage does not fail the request that queued it.

## Coming soon

- **Metrics:** a Prometheus `/metrics` endpoint and Stripe webhook metrics.
- **Security:** structured validation errors.
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
