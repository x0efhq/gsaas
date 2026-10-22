---
title: How to publish a webhook event
weight: 11
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

An organization admin registers a URL with `POST /organizations/{orgID}/webhooks` and the event name in `events`. The signing headers a receiver checks are on the [Webhooks]({{< ref "docs/reference/webhooks.md" >}}) page.

The alias collision: the how-to page file will be publish-a-webhook-event.md and the reference will be webhooks.md. relref "webhooks" might hit the how-to if I alias /docs/webhooks/ onto the how-to AND also have a page named webhooks. I'll name the reference page webhooks.md and put the old aliases on the reference page, not the how-to. The how-to can link to it. Old URL /docs/webhooks/ should go to the reference because that's where the signature contract is, which is what an integrator needs. The how-to is for the person adding an event.

Remove aliases from the how-to and put them on the reference page.