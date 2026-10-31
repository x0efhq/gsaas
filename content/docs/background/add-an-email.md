---
title: Send an email
weight: 52
aliases:
  - /docs/email/
  - /docs/services/email/
  - /docs/how-to/add-an-email/
---

# Send an email

```
module publishes event → app/subscribe.go renders → email.send job → worker → SMTP or log
```

Modules do not send mail. They publish an event. A handler in `app/subscribe.go` renders a template and queues it as an `email.send` job. The worker sends it. Retries and system-job rules are on the [Jobs]({{< relref "/docs/reference/jobs.md" >}}) page.

SMTP settings are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}). With `SMTP_HOST` empty, the message is written to the server log.

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

The request that published the event does not wait on the mail server.
