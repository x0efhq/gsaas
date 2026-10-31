---
title: Send a new webhook event to customers
weight: 53
aliases:
  - /docs/how-to/publish-a-webhook-event/
---

# Send a new webhook event to customers

Customer endpoints already receive `project.created` and `org.member.added`. To send another event, publish it from the module and list it for delivery. Signing, retries, and the worker are shared.

```
Service ─publish─▶ bus ─▶ webhookEvents (app/subscribe.go) ─▶ Dispatch ─▶ webhooks.deliver job ─▶ worker ─signed POST─▶ customer URL
```

1. Publish the event from the module after the write commits. Use snake_case `json` tags on the payload.

```go
// projects/events.go
const EventCreated = "project.created"

type Created struct {
	ID    uuid.UUID `json:"id"`
	OrgID uuid.UUID `json:"org_id"`
	Name  string    `json:"name"`
}

// projects/service.go — in Create, after the write
events.Publish(ctx, s.bus, EventCreated, Created{ID: p.ID, OrgID: p.OrgID, Name: p.Name})
```

2. Add the event to `webhookEvents` in `app/subscribe.go`. The function returns the payload's organization id.

```go
projects.EventCreated: func(p any) (uuid.UUID, bool) {
	e, ok := p.(projects.Created)
	return e.OrgID, ok
},
```

An organization admin registers a URL with `POST /organizations/{orgID}/webhooks` and the event name in `events`. The signing headers a receiver checks are on the [Webhooks]({{< relref "/docs/reference/webhooks.md" >}}) page.
