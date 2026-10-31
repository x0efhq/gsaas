---
title: How to publish a webhook event
weight: 53
aliases:
  - /docs/how-to/publish-a-webhook-event/
---

# How to publish a webhook event

Customer endpoints already receive `project.created` and `org.member.added`. To send another event, publish it from the module and list it for delivery. Signing, retries, and the worker are shared.

1. Publish the event from the module after the write commits. Use snake_case `json` tags on the payload.
2. Add the event to `webhookEvents` in `app/subscribe.go`. The function returns the payload's organization id.

```go
projects.EventCreated: func(p any) (uuid.UUID, bool) {
	e, ok := p.(projects.Created)
	return e.OrgID, ok
},
```

An organization admin registers a URL with `POST /organizations/{orgID}/webhooks` and the event name in `events`. The signing headers a receiver checks are on the [Webhooks]({{< relref "/docs/reference/webhooks.md" >}}) page.
