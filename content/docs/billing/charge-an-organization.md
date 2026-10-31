---
title: How to charge an organization
weight: 41
aliases:
  - /docs/services/billing/
  - /docs/how-to/charge-an-organization/
---

# How to charge an organization

Charge one organization through Stripe Checkout. Stripe events are stored immediately and applied by a job. The worker must be running. See [Jobs]({{< relref "/docs/reference/jobs.md" >}}).

1. In Stripe, create a product with a recurring price. Copy the price id (`price_…`).
2. Set `STRIPE_SECRET_KEY`, `STRIPE_PRICE_PRO`, `STRIPE_WEBHOOK_SECRET`, and `FRONTEND_BASE_URL` in `.env`. Names are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}). Without `STRIPE_SECRET_KEY`, billing routes return 503. The rest of the API still starts.
3. Forward Stripe to the local API and copy the signing secret `stripe listen` prints into `STRIPE_WEBHOOK_SECRET`:

```bash
stripe listen --forward-to localhost:5000/webhooks/stripe
```

4. Start the worker in another terminal:

```bash
go run ./cmd/worker
```

5. As an owner or admin of the organization, create a checkout session:

```bash
curl -X POST localhost:5000/organizations/<org_id>/billing/checkout \
  -H 'Authorization: Bearer <access_token>' \
  -H 'Content-Type: application/json' \
  -d '{"plan":"pro"}'
```

The response contains a Stripe Checkout URL. An API key cannot call this route.

Select these webhook events in Stripe: `checkout.session.completed`, `customer.subscription.created`, `customer.subscription.updated`, and `customer.subscription.deleted`.

To refuse a feature unless the organization is on Pro, see [How to gate a feature by plan]({{< relref "gate-a-feature-by-plan" >}}). Plan codes and gating rules are on [Billing]({{< relref "/docs/reference/billing.md" >}}).

A Stripe subscription in `trialing` counts as on the plan. `POST /organizations/{orgID}/billing/portal` returns the customer portal URL after you enable the portal in Stripe.
