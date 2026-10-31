---
title: Introduction
weight: 11
---

# Introduction

gsaas is a multi-tenant Go REST API you own: auth, teams, billing, jobs, and webhooks, ready to extend.

## TLDR

gsaas is the backend for a SaaS: a Go API with sign-in, teams, billing and jobs already wired. Clone it, then run:

```bash
cp .env.example .env
make seed
make run
```

The API is up on port 5000. You own every file.

## What you get

- Email and password sign-in, magic links, Google and GitHub OAuth, or Supabase Auth
- Personal and team organizations, invites, roles, and permissions
- Stripe checkout, portal, and plan gating per organization
- Organization API keys, durable background jobs, outbound signed webhooks
- File uploads (disk by default; S3 is a code switch), platform admin stats, audit log
- OpenAPI at `/openapi.yaml`, interactive docs at `/docs`, OpenTelemetry when `OTLP_ENDPOINT` is set
- Postgres by default, or SQLite after a code switch; Docker image with `/server`, `/worker`, and `/migrate`

## What you do not get

- A frontend or admin UI. Clients call the API with a bearer token.
- Runtime switches for the database, auth mode, or file store. Those are edits in `app.New`.
- A hosted service. You run the code you bought.

## Simplest path

1. [Run the API and make a first call]({{< relref "first-call" >}}).
2. [Add a feature]({{< relref "/docs/build/add-a-module.md" >}}), copying `projects/`.
3. [Use built-in sign-in or Supabase Auth]({{< relref "/docs/auth/choose-auth.md" >}}) if you need Supabase.
4. [Charge a customer with Stripe]({{< relref "/docs/billing/charge-an-organization.md" >}}) when you sell a plan.
5. [Deploy]({{< relref "/docs/deploy/" >}}) with the production checklist, then a host page.

Why packages and `app/` are split is on [Why the code is laid out this way]({{< relref "why-this-shape" >}}).

## License

A purchase on Gumroad gives you access to the private GitHub repository. One license covers one person or company, with unlimited developers on your team and unlimited products, including client work. You may not resell the code or publish it. The full terms are in `LICENSE` in the repository.
