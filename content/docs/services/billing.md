---
title: Billing
weight: -15
aliases:
  - /docs/billing/
---

# Billing with Stripe

Code: `billing/`, `adapters/stripe/`, `adapters/postgres/billing.go`

Billing charges each organization (team or personal workspace) through Stripe. Users pay in Stripe Checkout, Stripe tells gsaas through a webhook, and gsaas keeps the org's subscription in your database.

**What you get**

- **Subscriptions per org.** Each organization gets its own Stripe customer and subscription.
- **Checkout and portal.** One call returns a Stripe Checkout URL; another returns the Stripe customer portal URL, where users change cards or cancel.
- **Plan gating.** `RequirePlan` middleware answers `402` when an org isn't on a plan.
- **Safe webhook sync.** Events are signature-checked, stored once, and applied by the job queue with retries.
- **One-time purchases.** An optional one-time price, stored as a payment.

> [!WARNING]
> Run the worker (`go run ./cmd/worker`) in every environment. Stripe events are stored right away but applied by a background job; without the worker, subscriptions never update. See [Jobs]({{< relref "jobs" >}}).

## Check an org's plan

Gate routes with `RequirePlan` from the billing handler, mounted after the `tenant` middleware in `router` (`app/app.go`). For example, for your own `reports` module:

```go
r.With(authed, tenant, billingHandler.RequirePlan(billing.PlanPro)).Mount("/reports", reportsHandler.Routes())
```

In `app.New`, call the service directly:

```go
ok, err := billingSvc.HasPlan(ctx, orgID, billing.PlanPro)
```

An org is on a plan when its subscription status is `active` or `trialing` and its price matches the plan's price. Any other status, such as `past_due` or `canceled`, counts as not on the plan. There is no HTTP route that returns an org's plan.

## Keys and environment variables

Set these in `.env` (all settings are listed in `.env.example`):

| Variable | What it is |
| --- | --- |
| `STRIPE_SECRET_KEY` | Your Stripe secret key (Dashboard → Developers → API keys). Use a test key until launch. |
| `STRIPE_WEBHOOK_SECRET` | The signing secret of your webhook endpoint (`whsec_…`). Required: unsigned or wrongly signed events are rejected. |
| `STRIPE_PRICE_PRO` | Price ID (`price_…`) of your recurring plan. Checkout plan `pro` uses it. |
| `STRIPE_PRICE_ITEM` | Optional price ID of a one-time purchase. Checkout plan `item` uses it, in payment mode. |
| `FRONTEND_BASE_URL` | Where users land after checkout or the billing portal. Empty uses `APP_BASE_URL`. |
| `CHECKOUT_SUCCESS_PATH`, `CHECKOUT_CANCEL_PATH`, `PORTAL_RETURN_PATH` | Paths on that URL for each outcome. |

Without `STRIPE_SECRET_KEY` the app still boots. Billing routes answer `503` until it is set.

## Plans and prices

1. In Stripe, create a product with a recurring price for your paid plan, and copy its price ID into `STRIPE_PRICE_PRO`.
2. Optionally create a one-time price for `STRIPE_PRICE_ITEM`.
3. Every organization without a subscription is on the free plan.

## Common setups

- **One paid plan.** The default: set `STRIPE_PRICE_PRO`. Checkout uses plan `pro`.
- **Several tiers, or monthly and annual.** Each plan is one Stripe price. Pass a `Plans` map to `billing.Config` in `app.New` (`app/app.go`); it replaces `pro` and `item`. Add a constant for each plan code next to those in `billing/plan.go`.

```go
billing.Config{
	Plans: map[string]billing.Plan{
		"pro_monthly": {PriceID: "price_..."},
		"pro_annual":  {PriceID: "price_..."},
		"team":        {PriceID: "price_..."},
	},
	// ...
}
```

A plan with no `Mode` is a subscription; set `Mode: billing.ModePayment` for a one-time price. `RequirePlan` checks one plan at a time, so monthly and annual are separate plan codes.

- **Trials.** gsaas doesn't start trials itself. A Stripe subscription in `trialing` status counts as on the plan.

## The webhook

**Events to select** in Stripe (these are the ones gsaas handles; others are ignored):

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

**Local development:**

```bash
stripe listen --forward-to localhost:5000/webhooks/stripe
```

`stripe listen` prints a `whsec_…` secret. Put it in `STRIPE_WEBHOOK_SECRET`. Use your `PORT` if it isn't 5000.

**Production:** in Dashboard → Developers → Webhooks, add the endpoint `https://<your-api-host>/webhooks/stripe` with the events above, and set its signing secret as `STRIPE_WEBHOOK_SECRET`.

Run the worker in every environment; events are applied as background jobs.

## What happens on each event

```
Stripe ── POST /webhooks/stripe ──> verify signature
                                         │
                                 store event (deduped by Stripe event id)
                                         │
                                 enqueue job ──> worker
                                                   │
                     find org (checkout reference or Stripe customer)
                                                   │
                  update subscription row, or record one-time payment
                                                   │
                           publish subscription.changed
```

- **Signature:** checked with `STRIPE_WEBHOOK_SECRET`. A bad signature gets `401`.
- **Dedupe:** each Stripe event is stored once. A replayed event is a no-op.
- **Retries:** processing runs on the job queue and is retried on failure.
- **What syncs:** the org's subscription status, price, Stripe subscription ID and current period end. One-time purchases are stored as payments.
- **Deleted orgs:** an event for an organization or customer that no longer exists is marked handled and skipped.

## Checkout and portal

Owners and admins of an organization call:

- `POST /organizations/{orgID}/billing/checkout` with `{"plan":"pro"}` (or `"item"`), which returns a Stripe Checkout URL.
- `POST /organizations/{orgID}/billing/portal`, which returns a Stripe customer portal URL. Enable the customer portal in your Stripe settings first.

These routes need a signed-in user. API keys can't use them.

## Reacting to changes

After a subscription change is saved, gsaas publishes the `subscription.changed` event with the org ID and new status. Subscribe to it in `app/subscribe.go` to send emails, unlock features or notify your own systems:

```go
events.Subscribe(bus, billing.EventSubscriptionChanged, func(ctx context.Context, e events.Event[billing.SubscriptionChanged]) error {
	// e.Payload.OrgID, e.Payload.Status
	return nil
})
```
