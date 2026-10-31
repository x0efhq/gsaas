---
title: Add an endpoint
weight: 22
aliases:
  - /docs/how-to/add-an-endpoint/
---

# Add an endpoint

Add a route to a module that already exists. The organization id comes from the authenticated caller, not from the request body. Tenant status codes are on the [API]({{< relref "/docs/reference/api.md" >}}) page.

```
request ─▶ authed ─▶ tenant (X-Org-ID / path / key) ─▶ RequirePerm ─▶ Handler ─▶ Service(orgID) ─▶ Store
            401            403/404                        403
```

1. Add the service method. Pass `orgID` into every store call that reads or writes tenant data.

```go
// projects/service.go
func (s *Service) Get(ctx context.Context, orgID, id uuid.UUID) (Project, error) {
	if orgID == uuid.Nil {
		return Project{}, ErrOrgRequired
	}
	return s.store.Get(ctx, orgID, id)
}
```

2. Add the handler and register it in `Routes()`.

```go
// projects/handler.go
r.With(h.guard.RequirePerm(PermRead)).Get("/{id}", h.Get)

func (h *Handler) Get(w http.ResponseWriter, r *http.Request) {
	oid, err := orgID(r)
	if err != nil {
		httpx.Fail(w, err)
		return
	}
	id, err := httpx.PathID(r)
	if err != nil {
		httpx.Fail(w, err)
		return
	}
	p, err := h.service.Get(r.Context(), oid, id)
	if err != nil {
		httpx.Fail(w, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, "project", p)
}
```

3. Gate the route with `guard.RequirePerm`. A new permission is an `auth.Perm` constant in that module, granted to the lowest role that should have it in `app/rbac.go`.

```go
// projects/handler.go
const PermRead auth.Perm = "projects:read"

// app/rbac.go
organization.RoleViewer: {organization.PermOrgRead, organization.PermOrgMembersRead, projects.PermRead},
```

4. Mount a tenant-scoped route with `r.With(authed, tenant, ...)`. Add its prefix to `tenantPrefixes`.

```go
// app/app.go
// Tenant routes: list the prefix in tenantPrefixes in isolation_test.go.
r.With(authed, tenant).Mount("/projects", projectHandler.Routes())

// app/isolation_test.go
var tenantPrefixes = []string{"/organizations/{orgID}", "/projects", "/jobs"}
```

5. Add a cross-tenant case to `TestTenantIsolation`.

```go
// app/isolation_test.go — user A reaching for org B's project
{method: "GET", path: projBPath, orgHeader: orgB, want: 403},
{method: "GET", path: projBPath, orgHeader: orgA, want: 404},
```

6. Document the route in `app/openapi.yaml`. `TestOpenAPI_documentsEveryRoute` fails while the route is missing.

```yaml
# app/openapi.yaml
/projects/{id}:
  parameters:
    - $ref: "#/components/parameters/XOrgID"
    - $ref: "#/components/parameters/ID"
  get:
    tags: [projects]
    summary: Get a project. Requires `projects:read`.
    responses:
      "200": { $ref: "#/components/responses/Project" }
      "401": { $ref: "#/components/responses/Error" }
      "403": { $ref: "#/components/responses/Error" }
      "404": { $ref: "#/components/responses/Error" }
```

7. Run `make check`. See [Run the tests]({{< relref "run-the-tests" >}}).

A route that only a signed-in user may call, not an API key, belongs inside `auth.RequireUser`. Add a case to `TestTenantIsolation_apiKey`.

Respond with the `platform/httpx` writers. Lists take `starting_after` and return `has_more`.
