---
title: Permissions
weight: 93
aliases:
  - /docs/organizations/
  - /docs/services/organizations/
---

# Permissions

A route asks for a permission. `app/rbac.go` maps an organization role to the permissions it grants. `RequirePerm` allows a member whose role has the permission, and an API key created with it. `RequireRole` allows a signed-in member at or above that role. An API key has no role, so `RequireRole` returns 403.

No caller returns 401. A caller who lacks the permission returns 403.

| Action | viewer | member | admin | owner |
| --- | --- | --- | --- | --- |
| Read the org, list and read projects | ✓ | ✓ | ✓ | ✓ |
| List members | ✓ | ✓ | ✓ | ✓ |
| Leave the org | ✓ | ✓ | ✓ | |
| List and read jobs | | ✓ | ✓ | ✓ |
| Cancel jobs | | | ✓ | ✓ |
| Create, update, and delete projects | | | ✓ | ✓ |
| Update the org | | | ✓ | ✓ |
| Manage billing | | | ✓ | ✓ |
| Invite members, list and revoke invites | | | ✓ | ✓ |
| Change roles, remove members | | | ✓ | ✓ |
| Manage API keys | | | ✓ | ✓ |
| Manage webhooks | | | ✓ | ✓ |
| List audit log (`audit:read`) | | | ✓ | ✓ |
| Delete the org | | | | ✓ |

Billing, deleting the org, invites, API keys, and leaving also require a signed-in user.

Every organization has one owner. A request to grant, remove, demote, or have the owner leave returns 409. A personal organization accepts no invites and is not deleted through the organization route. It is deleted with its owner's account.

An API key is created with `org:api_keys`. Each permission on the key must be one the creator's role holds, or the request returns 403. The raw key is returned once. A key reaches only its own organization. `/me`, `/users`, `/files`, `POST /organizations`, and the invite, API-key, and billing routes reject API keys.

Platform permissions (`platform:stats`, `platform:users:list`, `platform:users:manage`) are never on an organization role or an API key. They are added only to a platform admin's session. See [Platform admin]({{< relref "platform-admin" >}}).
