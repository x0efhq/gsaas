---
title: How to gate a feature by plan
weight: 7
---

# How to gate a feature by plan

Refuse a feature unless the organization holds the plan. `billing.Config.Plans` is the catalog. `app.New` fills `pro` and `item` from `STRIPE_PRICE_PRO` and `STRIPE_PRICE_ITEM`. An empty price stays in the map: the plan is known and not for sale. Add a plan by adding an entry in that literal. `billing.New` panics if `Plans` is nil.

`HasPlan` is true when the org has an active or trialing subscription on that plan's price. A plan that is not for sale is held by nobody. An unknown plan is an error. `*billing.Service` implements `platform/plan.Checker`.

## Gate a route

Mount `RequirePlan` after `tenant`, with the route's permission. `RequirePlan` checks the catalog first. No price is 503. A miss is 402 (`billing.ErrPlanRequired`). `GET /projects/{id}/report` is the example. It returns the project. The other project routes stay open. Copy the call, then delete the sample route when you no longer need it.

```go
r.With(authed, tenant, billingSvc.RequirePlan(billing.PlanPro), guard.RequirePerm(projects.PermRead)).
    Get("/projects/{id}/report", projectHandler.Get)
```

Document the 402 in `app/openapi.yaml`. Add a cross-tenant case to `TestTenantIsolation` when the route is tenant-scoped. Another organization's `X-Org-ID` returns 403. Another organization's id returns 404 once the caller is on the plan. The plan check runs first, so a free org gets 402 before a missing id can return 404.

## Cap a write

Use this when the free plan is allowed up to a count, such as a maximum number of projects. The domain takes `plan.Checker` and does not import `billing`. `app.New` passes `billingSvc` with no condition. Count before the insert.

`projects.Create` is the example. `PROJECT_FREE_MAX` defaults to 3. At the cap, an org that is not on the plan gets `projects.ErrPlanRequired` (402). With no pro price, nobody is on pro, so the free cap applies.

```go
projects.New(store, queue, bus, clk, billingSvc, projects.Config{
    FreeMax: cfg.ProjectFreeMax,
    Plan:    billing.PlanPro,
})
```

To cap another domain, take `plan.Checker`, call `HasPlan`, and pass `billingSvc`. Point `Plan` at that domain's plan code.

## Add a plan

Add the plan to the catalog, then point the check at that code. You do not add a second checker.

1. Add a constant in `billing/plan.go`, for example `PlanTeam = "team"`.
2. Add a `STRIPE_PRICE_TEAM` field in `platform/config/config.go` the same way as `STRIPE_PRICE_PRO`, and list it in `.env.example`.
3. In `app.New`, add an entry next to `pro` and `item`:

```go
billing.PlanTeam: {PriceID: cfg.StripePriceTeam, Mode: billing.ModeSubscription},
```

4. For a whole route, mount `billingSvc.RequirePlan(billing.PlanTeam)`.
5. For a write cap, keep passing `billingSvc` and set `Config.Plan` to `billing.PlanTeam`.

Checkout `plan` is the catalog key. Charge the new plan the same way as `pro`. See [How to charge an organization]({{< relref "charge-an-organization" >}}).
