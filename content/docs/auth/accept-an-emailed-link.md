---
title: How to accept an emailed link
weight: 33
aliases:
  - /docs/authentication/
  - /docs/services/authentication/
  - /docs/how-to/accept-an-emailed-link/
---

# How to accept an emailed link

Magic-link sign-in and organization invites both open a page on your frontend. The page must not spend the token when it loads. Mail scanners open links, and the token works once.

The link is `FRONTEND_BASE_URL` plus `MAGIC_LINK_PATH` (default `/auth/magic-link`) or `INVITE_ACCEPT_PATH` (default `/invites/accept`), with `?token=<token>`. When `FRONTEND_BASE_URL` is empty, the API serves its own confirm page at that path.

1. Read `token` from the query string.
2. Show a button. Do not send the token from the page load.
3. When the user clicks, post `{"token": "<token>"}` to `/auth/magic-link/verify` for sign-in, or to `/invites/accept` for an invite.

Both responses are a session: `access_token`, `refresh_token`, `expires_at`, and `user_id`. Store them the same way you store a password sign-in.

A used, expired, or unknown sign-in token returns 401. An invite token in that state returns 404. Show a message that the link has expired and the user should request another.

An extra magic-link request past `MAGIC_LINK_HOURLY_LIMIT` still returns 202 and sends no mail.
