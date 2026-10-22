---
title: How to add an email
weight: 10
aliases:
  - /docs/email/
  - /docs/services/email/
---

# How to add an email

Modules do not send mail. They publish an event. A handler in `app/subscribe.go` renders a template and queues it as an `email.send` job, which sends it.

SMTP settings are on the [Configuration]({{< relref "configuration" >}}) page. With `SMTP_HOST` empty, the message is written to the server log.

1. Add a template to `platform/email/template.json` with `subject`, `text`, and `html`. The built-in names are `welcome`, `magic_link`, and `org_invite`.

```json
"welcome": {
  "subject": "Welcome to {{.AppName}}",
  "text": "Hi {{.Email}},\n\nYour {{.AppName}} account is ready.\n"
}
```

2. Subscribe to the event in `app/subscribe.go`. Render the template, set `To`, and call `enqueueEmail`.

```go
events.Subscribe(bus, identity.EventRegistered, func(ctx context.Context, e events.Event[identity.UserRegistered]) error {
	m, err := mailTmpl.Render("welcome", map[string]string{"AppName": appName, "Email": e.Payload.Email})
	if err != nil {
		return err
	}
	m.To = e.Payload.Email
	return enqueueEmail(ctx, jobs, m)
})
```

The `email.send` job sends the message in the background, so the request does not wait on the mail server. A failed send is retried by the job queue.
