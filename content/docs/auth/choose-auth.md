---
title: Use built-in sign-in or Supabase Auth
weight: 31
aliases:
  - /docs/how-to/choose-auth/
---

# Use built-in sign-in or Supabase Auth

Use one mode. API keys, organizations, and invites behave the same in both. See [Why the code is laid out this way]({{< relref "/docs/getting-started/why-this-shape.md" >}}) for why the switch is an edit in `app.New`.

Use built-in sign-in when gsaas should sign users up and in. That is the default. You change nothing. Passwords and magic links are mounted at `/auth`.

Use Supabase when the frontend already signs users in with Supabase Auth. gsaas then checks those tokens.

To switch to Supabase, edit `app.New` in `app/app.go`. Replace this line:

```go
sessions := auth.Verifier(idSvc)
```

with this, using your project URL (import `gsaas/adapters/supabase`):

```go
sessions, err := supabase.New(ctx, idSvc, "https://your-project.supabase.co")
if err != nil {
	return nil, err
}
```

gsaas then verifies Supabase tokens against the project's JWKS.

The `/auth` routes stay mounted. If the frontend signs users in only through Supabase, delete the `/auth` mount in `router` in the same file.

Keep the `identity` module. It still stores users. `POST /invites/accept` stays on gsaas in both modes.

Restart the API. A Supabase access token then authenticates the caller. On the first request, gsaas creates a user row whose id is the Supabase `sub`.
