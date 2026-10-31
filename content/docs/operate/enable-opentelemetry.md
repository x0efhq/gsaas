---
title: How to enable OpenTelemetry
weight: 71
aliases:
  - /docs/how-to/enable-opentelemetry/
---

# How to enable OpenTelemetry

HTTP requests and background jobs emit traces and metrics when `OTLP_ENDPOINT` is set. An empty value keeps `telemetry.Noop` (the default).

1. Run an OTLP/HTTP collector (port `4318` is common).
2. Set `OTLP_ENDPOINT` to the collector base URL, for example `http://localhost:4318`.
3. Restart the API and the worker. Both call `app.New` and share the same setting.

Traces and metrics export over OTLP/HTTP to that URL. The service name in telemetry is `APP_NAME`.

| Metric | Meaning |
| --- | --- |
| `http.server.request.count` | HTTP requests handled |
| `http.server.request.duration` | HTTP request duration (seconds) |
| `job.run.count` | Background jobs handled |
| `job.run.duration` | Job duration (seconds) |

Variable defaults are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}).
