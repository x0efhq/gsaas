---
title: How to choose local or Supabase auth
weight: 5
---

# How to choose local or Supabase auth

Use one mode. API keys, organizations, and invites behave the same in both.

Use local auth when gsaas should sign users up and in. That is the default. You change nothing. Passwords and magic links are already mounted at `/auth`.

Use Supabase when the frontend already signs users in with Supabase Auth. gsaas then only checks those tokens.

1. Add `SupabaseURL string` to `Config` in `platform/config/config.go`. In `Load`, set it to `strings.TrimRight(r.string("SUPABASE_URL", ""), "/")`.
2. Set `SUPABASE_URL` in `.env` to the project URL, such as `https://your-project.supabase.co`.
3. In `app.New`, replace `sessions := auth.ValidateToken(idSvc)` with the Supabase verifier. Import `gsaas/adapters/supabase`.

```go
sb, err := supabase.New(context.Background(), idSvc, cfg.SupabaseURL)
if err != nil {
	return nil, err
}
sessions := auth.ValidateToken(sb)
```

4. In `router`, delete the `/auth` mount:

```go
r.With(authLimit).Mount("/auth", identityHandler.AuthRoutes())
```

Keep the `identity` module. It still stores users. `POST /invites/accept` stays on gsaas in both modes.

Restart the API after the change. A Supabase access token then authenticates the caller. On the first request, gsaas creates a user row whose id is the Supabase `sub`.
