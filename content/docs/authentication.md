---
title: Authentication
weight: -17
---

# Authentication

Code: `platform/auth/`, `identity/`, `adapters/supabase/`, API keys in `organization/apikey.go`

Authentication decides who is calling the API. Clients send `Authorization: Bearer <token>` on each request. The token is either a session token (a signed-in user) or an organization API key (a server acting for one organization).

## Local or Supabase: which to pick

Use one auth mode.

- **Local (the default).** gsaas signs users up and in itself, with magic links or passwords. Nothing outside your server and Postgres is needed. Pick it unless you already use Supabase.
- **Supabase.** Supabase Auth handles sign-up and sign-in, and gsaas only checks its tokens. Pick it if your frontend already uses Supabase Auth. The swap is three small edits, listed under [Supabase auth](#supabase-auth).

API keys, organizations and invites work the same in both modes.

## Local auth (default)

The `identity` module issues and verifies session JWTs signed with `JWT_SECRET`. Access tokens last `ACCESS_TTL` and refresh tokens last `REFRESH_TTL`.

| Route | Purpose |
| --- | --- |
| `POST /auth/signup` | Create an account |
| `POST /auth/magic-link` | Email a one-time sign-in link |
| `GET /auth/magic-link?token=...` | Confirm page for the emailed link, when you have no frontend |
| `POST /auth/magic-link/verify` | Exchange the link token for a session |
| `POST /auth/signin` | Sign in with email and password |
| `POST /auth/refresh` | Get a new access token |
| `POST /auth/signout` | End the session |
| `PUT /me/password` | Set an optional password |

Magic links are the default sign-in and expire after `MAGIC_LINK_TTL`. Each address gets at most `MAGIC_LINK_HOURLY_LIMIT` links per hour; extra requests still return 202 but send no email. `/auth` routes are rate limited (`AUTH_RATE_LIMIT`).

## Emailed links

Sign-in and invite emails carry a one-time token in a link:

- With `FRONTEND_BASE_URL` set, links open your frontend: `FRONTEND_BASE_URL` + `MAGIC_LINK_PATH` (default `/auth/magic-link`) or `INVITE_ACCEPT_PATH` (default `/invites/accept`), with `?token=<token>`.
- Without it, links open the API's own confirm page at the same paths, whose button posts the token for the user.

Your frontend page must:

1. Read `token` from the query string.
2. Show a button such as "Sign in" or "Accept invite". Don't use the token on page load: email scanners and link previews open links, and would use up the one-time token before the user does.
3. On click, `POST` `{"token": "<token>"}` to `/auth/magic-link/verify` (sign-in) or `/invites/accept` (invite). Both return a session (`access_token`, `refresh_token`, `expires_at`, `user_id`) that you store like a sign-in.

A used, expired or unknown token gets 401 (sign-in) or 404 (invite); show a "link expired, request a new one" message.

## Supabase auth

`adapters/supabase` verifies access tokens locally through JWKS (ES256 or RS256) and checks `iss`, `aud` and `exp`. On a user's first request, a matching user row is created with the same ID as the Supabase `sub`.

To use Supabase Auth instead of local auth:

1. Set `SUPABASE_URL` (from `.env.example`):

```bash
# Tokens are checked against SUPABASE_URL/auth/v1/.well-known/jwks.json.
SUPABASE_URL=https://your-project.supabase.co
```

2. In `app.New` (`app/app.go`), swap the token verifier for the commented Supabase block and import `gsaas/adapters/supabase`:

```go
// Before
sessions := auth.ValidateToken(idSvc)

// After
sb, err := supabase.New(context.Background(), idSvc, cfg.SupabaseURL)
if err != nil {
	return nil, err
}
sessions := auth.ValidateToken(sb)
```

3. In `router`, remove the `/auth` mount:

```go
r.With(authLimit).Mount("/auth", identityHandler.AuthRoutes())
```

Keep the `identity` module: it still stores users. Invite acceptance (`POST /invites/accept`) stays local in both modes.

## API keys

API keys belong to an organization and act for it with a fixed list of permissions (`perms`) and no user. Tokens starting with `ak_` are checked as API keys; every other token is checked as a session.

| Route | Purpose |
| --- | --- |
| `POST /organizations/{orgID}/api-keys` | Create a key |
| `GET /organizations/{orgID}/api-keys` | List keys |
| `DELETE /organizations/{orgID}/api-keys/{keyID}` | Revoke a key |

Creating a key needs `org:api_keys`. Each perm must be one your own role holds, or the request gets 403. An empty list reaches only routes that need no permission. The raw key is returned once.

```json
POST /organizations/{orgID}/api-keys
{"name": "ci", "perms": ["jobs:read", "projects:write"]}
```

A key can only reach its own organization. Some routes need a signed-in user and return 403 for API keys: `/me` (including `/me/organizations`), `/users`, `/files`, `POST /organizations`, leaving an organization, and the organization invites, API keys and billing routes.

## Users

| Route | Purpose |
| --- | --- |
| `GET`, `PATCH`, `DELETE /me` | Read, update or delete your account |
| `GET /users` | List users (platform admins only, `platform:users:list`) |
| `GET`, `PATCH /users/{id}` | Read or update yourself, or any user with `platform:users:manage` (platform admins) |
