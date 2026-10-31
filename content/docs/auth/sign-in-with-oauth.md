---
title: Sign in with Google or GitHub OAuth
weight: 32
aliases:
  - /docs/how-to/sign-in-with-oauth/
---

# Sign in with Google or GitHub OAuth

OAuth matches users by the provider's verified email. A new email creates a passwordless account. An unverified password signup for the same email is reclaimed, like magic link. Provider code lives in `adapters/oauth/`.

## Configure the API

Set client credentials for each provider you use. Leave a provider empty to keep it unavailable (`503` on start).

```sh
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

Variable names are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}).

Register these redirect URLs with the provider:

- `{APP_BASE_URL}/auth/oauth/google/callback`
- `{APP_BASE_URL}/auth/oauth/github/callback`

State and PKCE use `JWT_SECRET` as the HMAC key, same as session signing.

## Browser flow

```
browser ─GET /auth/oauth/google─▶ API ─302+state cookie─▶ Google
Google ─callback─▶ API (check state, verified email) ─302 ?code=─▶ frontend
frontend ─POST /auth/oauth/exchange {code}─▶ API ─▶ session JSON
```

1. Send the user to `GET /auth/oauth/google` or `GET /auth/oauth/github`. The API sets a state cookie and redirects to the provider.
2. The provider calls back. The API checks state, reads the verified email, and redirects to the frontend with `?code=<one-time-code>`.
3. Exchange the code:

```bash
curl -X POST localhost:5000/auth/oauth/exchange \
  -H 'Content-Type: application/json' \
  -d '{"code":"<one-time-code>"}'
```

The response matches `/auth/signin`:

```json
{
  "object": "token",
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "expires_at": "...",
    "user_id": "..."
  }
}
```

The one-time code uses the same lifetime as `MAGIC_LINK_TTL`. A second exchange returns 401.

When `FRONTEND_BASE_URL` is empty, the redirect can land on the API's no-frontend fallback page, which shows the code and does not consume it.

Route details are on the [API]({{< relref "/docs/reference/api.md" >}}) page.
