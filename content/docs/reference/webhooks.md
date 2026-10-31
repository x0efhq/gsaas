---
title: Webhooks
weight: 95
aliases:
  - /docs/webhooks/
  - /docs/services/webhooks/
---

# Webhooks

Customer endpoints receive POSTs from the worker, not from the request that published the event. Delivery is at-least-once. The event `id` is stable across retries. Receivers dedupe on it.

A non-2xx response, a timeout of 10 seconds, or a redirect is a failure and is retried. Private, loopback, link-local, and other reserved addresses are refused after DNS resolution and are not retried. Creating an endpoint whose URL is such an address returns 400. URLs must be `https` unless `WEBHOOK_ALLOW_INSECURE=true`, which is local only.

An organization may register `WEBHOOK_MAX_ENDPOINTS` endpoints (default 20). The create response includes `secret` once. List responses omit it.

To add an event type, see [How to publish a webhook event]({{< relref "/docs/background/publish-a-webhook-event.md" >}}).

## Body

```json
{
  "id": "evt_3f2a...",
  "type": "project.created",
  "created_at": "2026-10-13T19:47:00Z",
  "org_id": "…",
  "data": {}
}
```

Events shipped with the repository:

| `type` | `data` fields |
| --- | --- |
| `project.created` | `id`, `org_id`, `name` |
| `org.member.added` | `org_id`, `user_id`, `role` |
| `org.member.removed` | `org_id`, `user_id` |
| `org.member.role.changed` | `org_id`, `user_id`, `role`, `previous_role` |
| `subscription.changed` | `org_id`, `status` |

Register the event names you want on the endpoint's `events` array.

## Signature

```
X-Webhook-Id: evt_3f2a...
X-Webhook-Timestamp: 1760384820
X-Signature: v1=<hex hmac-sha256(secret, timestamp + "." + body)>
```

`X-Webhook-Timestamp` is Unix seconds. Compare the recomputed HMAC to the header. Reject a timestamp older than a few minutes to ignore a replay.
