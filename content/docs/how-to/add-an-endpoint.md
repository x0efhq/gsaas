---
title: How to add an endpoint
weight: 2
---

# How to add an endpoint

Add a route to a module that already exists. The organization id comes from the authenticated caller, not from the request body.

1. Add the service method. Pass `orgID` into every store call that reads or writes tenant data.
2. Add the handler and register it in `Routes()`.
3. Gate the route with `guard.RequirePerm`. A new permission is an `auth.Perm` constant in that module, granted to the lowest role that should have it in `app/rbac.go`.
4. Document the route in `app/openapi.yaml`. `TestOpenAPI_documentsEveryRoute` fails while the route is missing.
5. Mount a tenant-scoped route with `r.With(authed, tenant, ...)`. Add its prefix to `tenantPrefixes`.
6. Add a cross-tenant case to `TestTenantIsolation`. Another organization's `X-Org-ID` returns 403. Another organization's id in the path returns 404.
7. Run `make check`.

A route that only a signed-in user may call, not an API key, belongs inside `auth.RequireUser`. Add a case to `TestTenantIsolation_apiKey`.

Respond with the `platform/httpx` writers. Lists take `starting_after` and return `has_more`.
