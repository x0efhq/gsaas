---
title: How to choose local or Supabase auth
weight: 5
---

# How to choose local or Supabase auth

Use one mode. API keys, organizations, and invites behave the same in both.

Use local auth when gsaas should sign users up and in. That is the default. You change nothing. Passwords and magic links are mounted at `/auth`.

Use Supabase when the frontend already signs users in with Supabase Auth. gsaas then checks those tokens.

To switch to Supabase, edit `app.New` in `app/app.go`. Replace this line:

```go
sessions, stopAuth, err := localSessions(idSvc)
```

with this line, using your project URL:

```go
sessions, stopAuth, err := supabaseSessions(ctx, idSvc, "https://your-project.supabase.co")
```

gsaas then verifies Supabase tokens against the project's JWKS.

The `/auth` routes stay mounted. If the frontend signs users in only through Supabase, delete the `/auth` mount in `router` in the same file.

Keep the `identity` module. It still stores users. `POST /invites/accept` stays on gsaas in both modes.

Restart the API. A Supabase access token then authenticates the caller. On the first request, gsaas creates a user row whose id is the Supabase `sub`.
