---
title: Gate a feature by plan
weight: 42
aliases:
  - /docs/how-to/gate-a-feature-by-plan/
---

# Gate a feature by plan

Refuse a feature unless the organization has an active or trialing Pro subscription. Set `STRIPE_PRICE_PRO` first. An empty price makes the check return 503.

`GET /projects/{id}/report` is the example. It returns the project, and the other project routes stay open. Copy its middleware. Coverage for the middleware is in `billing/gate_test.go` (`TestRequirePlan`).

## Gate a route

In `router` in `app/app.go`, mount the route after `tenant`:

```go
r.With(authed, tenant, s.billing.RequirePlan(billing.PlanPro), s.guard.RequirePerm(projects.PermRead)).
	Get("/projects/{id}/report", projectHandler.Get)
```

`RequirePlan` reads the org from the session or API key. A caller who is not on Pro gets 402. Document that response in `app/openapi.yaml`.

Add a cross-tenant case to `TestTenantIsolation` when the route is tenant-scoped. Tenant status codes are on the [API]({{< relref "/docs/reference/api.md" >}}) page. The plan check runs first, so a free org gets 402 before a missing id can return 404.

## Limit something inside a service

Use this when the free plan is allowed but capped, such as a maximum number of projects.

`projects` cannot import `billing`. In the module, define the check you need and pass `*billing.Service` from `app.New`:

```go
type plans interface {
	HasPlan(ctx context.Context, orgID uuid.UUID, plan string) (bool, error)
}
```

Call `HasPlan(ctx, orgID, "pro")` before the write. When it is false and the org is over the free limit, return a 402 sentinel defined in that module. `billing.ErrPlanRequired` is the same status the middleware uses.
