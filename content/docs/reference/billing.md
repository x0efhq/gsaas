---
title: Billing
weight: 98
---

# Billing

Stripe Checkout sells organization plans. `billing.Config.Plans` in `app.New` is the catalog. It is filled from environment variables, not from Stripe at runtime.

## Plan codes

| Code | Stripe mode | Price variable | Sold through checkout |
| --- | --- | --- | --- |
| `free` | not for sale | none | no |
| `pro` | subscription (`subscription`) | `STRIPE_PRICE_PRO` | yes, when the price id is set |
| `item` | one-time payment (`payment`) | `STRIPE_PRICE_ITEM` | yes, when the price id is set |

An empty price id stays in the map but checkout returns 503 for that plan. `RequirePlan` and `HasPlan` also return 503 when the plan's price id is empty.

`POST /organizations/{orgID}/billing/checkout` accepts `{"plan":"<code>"}`. Only `pro` and `item` are valid checkout codes. The route requires a signed-in org admin or owner. An API key cannot call it.

`POST /organizations/{orgID}/billing/portal` opens the Stripe customer portal. It requires a billing customer row for the organization.

## Subscriptions and gating

Webhook processing updates the organization's subscription row for recurring prices. Status values include `active`, `trialing`, and `canceled`.

`HasPlan(ctx, orgID, "pro")` is true when the subscription is `active` or `trialing` and its price id matches `STRIPE_PRICE_PRO`. `RequirePlan` on a route uses the same check and returns 402 when the org is not on the plan.

One-time checkout for `item` records a payment row. It does not grant `pro` through `HasPlan`. Gate features on subscriptions with `pro`, or implement a separate check if you sell one-time access.

Without `STRIPE_SECRET_KEY`, the billing processor is disabled and billing routes return 503.

## Configure checkout

Set `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, the price ids you sell, and `FRONTEND_BASE_URL` for return URLs. Variable names and link paths are on [Configuration]({{< relref "configuration" >}}).

To sell Pro subscriptions end to end, see [How to charge an organization]({{< relref "/docs/billing/charge-an-organization.md" >}}). To refuse a route unless the org is on Pro, see [How to gate a feature by plan]({{< relref "/docs/billing/gate-a-feature-by-plan.md" >}}).
