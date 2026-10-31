---
title: How to sign in with Google or GitHub OAuth
weight: 6
---

# How to sign in with Google or GitHub OAuth

OAuth matches users by the provider's verified email. A new email creates a passwordless account. An unverified password signup for the same email is reclaimed, like magic link.

## Configure the API

Set client credentials for each provider you use. Leave a provider empty to keep it unavailable (`503` on start).

| Variable | Meaning |
| --- | --- |
| `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | Google OAuth client |
| `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET` | GitHub OAuth app |
| `OAUTH_CALLBACK_PATH` | Path on the frontend that receives `?code=` after sign-in. Default `/auth/oauth/callback` |
| `FRONTEND_BASE_URL` | Origin of that page. Empty uses `APP_BASE_URL` |

Register these redirect URLs with the provider:

- `{APP_BASE_URL}/auth/oauth/google/callback`
- `{APP_BASE_URL}/auth/oauth/github/callback`

State and PKCE use `JWT_SECRET` as the HMAC key, same as session signing.

## Browser flow

1. Send the user to `GET /auth/oauth/google` or `GET /auth/oauth/github`. The API sets a state cookie and redirects to the provider.
2. The provider calls `GET /auth/oauth/{provider}/callback`. The API checks state, reads the verified email, and redirects to `FRONTEND_BASE_URL` + `OAUTH_CALLBACK_PATH` with `?code=<one-time-code>`.
3. Exchange the code for a session. Send only JSON:

```json
{"code": "<one-time-code>"}
```

Post it to `POST /auth/oauth/exchange`. The response matches `/auth/signin`: `access_token`, `refresh_token`, `expires_at`, and `user_id`.

The one-time code uses the same lifetime as `MAGIC_LINK_TTL`. A second exchange returns 401.

When `FRONTEND_BASE_URL` is empty, step 2 can land on `GET /auth/oauth/callback?code=…` on the API. That page shows the code and tells you to POST JSON to `/auth/oauth/exchange`; it does not consume the code.

Route details are on the [API]({{< relref "../reference/api.md" >}}) page. Environment variables are in [Configuration]({{< relref "../reference/configuration.md" >}}).
