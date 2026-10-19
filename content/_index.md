---
title: gsaas
---

# gsaas

**The SaaS backend you'd otherwise spend weeks building, ready on day one.** It includes sign-in, teams, permissions, Stripe billing, API keys, background jobs and outbound webhooks, all in Go.

Go · PostgreSQL · Stripe · optional Supabase Auth

[Get started]({{< relref "/docs/quickstart" >}})

## Who it's for

- Founders and developers launching a B2B or B2C SaaS in Go.
- Teams with their own web or mobile frontend that need the API behind it.
- People who build with AI coding agents. Conventions and recipes live in `AGENTS.md`, and `make check` says when the work is done.

It's a backend only: no frontend or admin UI, and no hosted service.

## Features

| | |
| --- | --- |
| **Auth** | Email and password, magic-link sign-in, or Supabase Auth |
| **Teams** | A personal workspace for every user, plus team organizations with email invites |
| **Access control** | Roles (owner, admin, member, viewer) plus per-action permissions mapped in one file |
| **Billing** | Stripe subscriptions per organization, customer portal, and plan gating ([guide]({{< relref "/docs/billing" >}})) |
| **API keys** | Per-organization keys for server-to-server access, each with its own list of permissions |
| **Jobs & events** | Durable jobs with retries, and typed events |
| **Outbound webhooks** | Signed, retried event delivery to your customers' URLs ([guide]({{< relref "/docs/webhooks" >}})) |
| **API docs** | OpenAPI 3.1 spec and an interactive reference at `/docs` |
| **Coming soon** | Metrics ([roadmap]({{< relref "/docs/roadmap" >}})) |

Also included: email sending, rate limiting, security headers, health checks, Docker and CI.

## Docs

- [Quickstart]({{< relref "/docs/quickstart" >}})
- [Billing]({{< relref "/docs/billing" >}})
- [Webhooks]({{< relref "/docs/webhooks" >}})
- [Roadmap]({{< relref "/docs/roadmap" >}})
