---
title: How to charge an organization
weight: 6
---

# How to charge an organization

Charge one organization through Stripe Checkout. The worker must be running. Stripe events are stored immediately and applied by a job. Without the worker, the subscription row never updates.

1. In Stripe, create a product with a recurring price. Copy the price id (`price_…`).
2. Set these in `.env`:

| Variable | Value |
| --- | --- |
| `STRIPE_SECRET_KEY` | The Stripe secret key. Use a test key until launch. |
| `STRIPE_PRICE_PRO` | The recurring price id. |
| `STRIPE_WEBHOOK_SECRET` | The webhook signing secret (`whsec_…`). |
| `FRONTEND_BASE_URL` | Where the browser returns after checkout. |

Without `STRIPE_SECRET_KEY`, billing routes return 503. The rest of the API still starts.

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

To refuse a route when the organization is not on `pro`, mount it with `billingHandler.RequirePlan(billing.PlanPro)` after `tenant`. A caller who is not on the plan gets 402.

Price ids, trials, and the customer portal are on the [Billing]({{< relref "billing" >}}) page.
