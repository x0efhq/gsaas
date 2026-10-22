---
title: Email
weight: -13
aliases:
  - /docs/email/
---

# Email

Code: `platform/email/`, `app/subscribe.go`

Email is sent over SMTP. Set `SMTP_HOST`, plus `SMTP_PORT`, `SMTP_TLS`, `SMTP_USER`, `SMTP_PASS` and `EMAIL_FROM` as needed. Any SMTP provider works. Without `SMTP_HOST`, emails are written to the log, which is handy for local development.

## Templates

Templates live in `platform/email/template.json`. Each has a `subject`, `text` and `html` body:

| Template | Sent when |
| --- | --- |
| `welcome` | A user registers |
| `magic_link` | A user asks for a sign-in link |
| `org_invite` | A user is invited to an organization |

## How emails are triggered

Modules don't send email directly. They publish events, and handlers in `app/subscribe.go` render a template and send it. To add an email, add a template and subscribe to the event that should trigger it.

A template in `platform/email/template.json`:

```json
"welcome": {
  "subject": "Welcome to {{.AppName}}",
  "text": "Hi {{.Email}},\n\nYour {{.AppName}} account is ready.\n\nThe {{.AppName}} team\n"
}
```

The handler that sends it, in `app/subscribe.go`:

```go
events.Subscribe(bus, identity.EventRegistered, func(ctx context.Context, e events.Event[identity.UserRegistered]) error {
	m, err := mailTmpl.Render("welcome", map[string]string{"AppName": appName, "Email": e.Payload.Email})
	if err != nil {
		return err
	}
	m.To = e.Payload.Email
	return mailer.Send(ctx, m)
})
```
