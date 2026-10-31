---
title: Build the magic link and invite pages
weight: 33
aliases:
  - /docs/authentication/
  - /docs/services/authentication/
  - /docs/how-to/accept-an-emailed-link/
---

# Build the magic link and invite pages

Magic-link sign-in and organization invites both open a page on your frontend. The page must not spend the token when it loads. Mail scanners open links, and the token works once.

| Link | Path var (default) | Verify endpoint | Bad token |
| --- | --- | --- | --- |
| Magic link | `MAGIC_LINK_PATH` (`/auth/magic-link`) | `POST /auth/magic-link/verify` | 401 |
| Invite | `INVITE_ACCEPT_PATH` (`/invites/accept`) | `POST /invites/accept` | 404 |

The link is `FRONTEND_BASE_URL` plus the path, with `?token=<token>`. When `FRONTEND_BASE_URL` is empty, the API serves its own confirm page at that path.

1. Read `token` from the query string.
2. Show a button. Do not send the token from the page load.
3. When the user clicks, post the token:

```bash
curl -X POST localhost:5000/auth/magic-link/verify \
  -H 'Content-Type: application/json' \
  -d '{"token":"<token>"}'
```

Both responses are a token object. Store them the same way you store a password sign-in:

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

A used, expired, or unknown sign-in token returns 401. An invite token in that state returns 404. Show a message that the link has expired and the user should request another.

Example button-not-on-load pattern:

```html
<button id="confirm">Continue</button>
<script>
  const token = new URLSearchParams(location.search).get("token");
  document.getElementById("confirm").onclick = () =>
    fetch("/auth/magic-link/verify", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ token }),
    });
</script>
```

An extra magic-link request past `MAGIC_LINK_HOURLY_LIMIT` still returns 202 and sends no mail.
