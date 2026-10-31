---
title: Export traces and metrics
weight: 71
aliases:
  - /docs/how-to/enable-opentelemetry/
---

# Export traces and metrics

HTTP requests and background jobs emit traces and metrics when `OTLP_ENDPOINT` is set. An empty value keeps `telemetry.Noop` (the default). Code: `adapters/otel/`, `platform/telemetry/`.

1. Run an OTLP/HTTP collector. Jaeger all-in-one is enough locally:

```bash
docker run --rm -p 16686:16686 -p 4318:4318 jaegertracing/all-in-one
```

2. Set the endpoint in `.env`:

```sh
OTLP_ENDPOINT=http://localhost:4318
```

3. Restart the API and the worker. Both call `app.New` and share the same setting.

Traces and metrics export over OTLP/HTTP to that URL. The service name in telemetry is `APP_NAME`.

| Metric | Meaning |
| --- | --- |
| `http.server.request.count` | HTTP requests handled |
| `http.server.request.duration` | HTTP request duration (seconds) |
| `job.run.count` | Background jobs handled |
| `job.run.duration` | Job duration (seconds) |

Variable defaults are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}).
