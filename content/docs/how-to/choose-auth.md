---
title: How to choose local or Supabase auth
weight: 5
---

# How to choose local or Supabase auth

Use one mode. API keys, organizations, and invites behave the same in both.

Use local auth when gsaas should sign users up and in. That is the default. You change nothing. Passwords and magic links are already mounted at `/auth`.

Use Supabase when the frontend already signs users in with Supabase Auth. gsaas then only checks those tokens.

Set both in `.env`:

```sh
AUTH_PROVIDER=supabase
SUPABASE_URL=https://your-project.supabase.co
```

gsaas then verifies Supabase tokens and does not mount `/auth`. Startup fails if `SUPABASE_URL` is missing.

Keep the `identity` module. It still stores users. `POST /invites/accept` stays on gsaas in both modes.

Restart the API. A Supabase access token then authenticates the caller. On the first request, gsaas creates a user row whose id is the Supabase `sub`.
