---
title: Webhooks
weight: -14
aliases:
  - /docs/webhooks/
---

# Outbound webhooks

Code: `webhooks/`, `adapters/postgres/webhooks.go`, `app/subscribe.go`

Your customers can get notified when something happens in their organization, without polling your API. A customer's Zapier flow or backend can learn the moment a project is created, for example.

## The flow

```
  your domain         events bus           webhooks            job queue          customer URL
      |                    |                    |                    |                    |
      |-- project.created->|                    |                    |                    |
      |   (after commit)   |---- deliver ------>|                    |                    |
      |                    |                    |-- enqueue 1 job -->|                    |
      |                    |                    |   per endpoint     |-- POST + sig ----->|
      |                    |                    |                    |<-- 2xx: done ------|
      |                    |                    |                    |    else: retry     |
```

The HTTP call never runs inside your API request, so a slow customer server can't slow your API.

## Endpoints

Roles with the `org:webhooks` permission (admins and owners, and API keys granted `org:webhooks`) manage endpoints:

| Method | Path | |
| --- | --- | --- |
| `POST` | `/organizations/{orgID}/webhooks` | Body `{"url": "https://…", "events": ["project.created"]}`. The response includes the `secret`, shown only once. |
| `GET` | `/organizations/{orgID}/webhooks` | Paginated list (`starting_after`, `has_more`). Secrets aren't included. |
| `DELETE` | `/organizations/{orgID}/webhooks/{id}` | Stops deliveries to that endpoint. |

URLs must be `https`. An organization can have up to 20 endpoints (`WEBHOOK_MAX_ENDPOINTS`).

Events available out of the box: `project.created`, `org.member.added`.

## Payload

```json
{
  "id": "evt_3f2a...",
  "type": "project.created",
  "created_at": "2026-10-13T19:47:00Z",
  "org_id": "…",
  "data": { "id": "…", "org_id": "…", "name": "Website redesign" }
}
```

`id` stays the same across retries. Delivery is at-least-once, so receivers should dedupe on it.

## Verifying the signature

Every request carries:

```
X-Webhook-Id: evt_3f2a...
X-Webhook-Timestamp: 1760384820
X-Signature: v1=<hex hmac-sha256(secret, timestamp + "." + body)>
```

The receiver recomputes the HMAC with its secret and compares. That proves the request came from you and wasn't altered. The timestamp (in seconds) lets receivers reject old replays, for example anything older than 5 minutes. It's the same scheme Stripe uses.

```go
mac := hmac.New(sha256.New, []byte(secret))
mac.Write([]byte(ts + "." + string(body)))
ok := hmac.Equal([]byte("v1="+hex.EncodeToString(mac.Sum(nil))), []byte(sig))
```

## Retries and safety

- A non-2xx response, a timeout (10 s) or a redirect counts as a failure, and the delivery is retried with backoff.
- Each delivery's latest status, attempt count and last error are stored per endpoint and event.
- Deliveries go only to public addresses, checked after DNS resolution. Private, loopback, link-local, carrier-grade NAT (`100.64.0.0/10`), multicast and other reserved ranges, including cloud metadata addresses, are blocked, and a blocked delivery isn't retried. Creating an endpoint with such an IP address in its URL gets 400.
- For local development, set `WEBHOOK_ALLOW_INSECURE=true` to allow `http://` and localhost receivers. Never set it in production.

## Adding your own event

1. Publish the event on the bus from your domain, with snake_case `json` tags on the payload struct.
2. Add it to `webhookEvents` in `app/subscribe.go`, with a function that returns the payload's organization ID.

```go
// app/subscribe.go
projects.EventCreated: func(p any) (uuid.UUID, bool) {
	e, ok := p.(projects.Created)
	return e.OrgID, ok
},
```

Delivery, signing and retries are shared.
