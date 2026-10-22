---
title: Jobs
weight: 4
aliases:
  - /docs/jobs/
  - /docs/services/jobs/
---

# Jobs

The worker process runs the queue. The API does not. A job whose name is missing from `jobs()` in `app/app.go` is canceled, not retried.

## Built-in jobs

| Job | When it runs | Without the worker |
| --- | --- | --- |
| `billing.process_webhook` | A Stripe event is stored | The subscription row stays unchanged |
| `billing.cancel_subscription` | An organization with a subscription is deleted | The subscription keeps running at Stripe |
| `webhooks.deliver` | A subscribed event is published | Customer endpoints receive nothing |
| `identity.expire_sessions` | Worker start, then every 15 minutes | Expired refresh tokens and invites remain |
| `projects.apply` | A project is created | The sample job never runs |

Mail is not a job. Event handlers send it directly.

`billing.process_webhook` and `identity.expire_sessions` are system jobs (`uuid.Nil`). They do not appear in `GET /jobs`.

## Status

`queued`, `running`, `succeeded`, `failed`, `canceled`. A job waiting to retry is `queued`. `GET /jobs?status=failed` filters the list. An unknown status returns 400.

A returned error is retried, 25 times unless `MaxAttempts` is set. After the last attempt the status is `failed`. `GET /jobs/{id}` then sets `error` without the error text. The text is in the worker log.

Wrap `worker.ErrPermanent` to stop retries. The status becomes `canceled`.

A handler must be idempotent. A retry can run the work again. `IdempotencyKey` also refuses a second enqueue of the same key.

The per-job timeout is 1 minute. On shutdown the worker waits `WORKER_SHUTDOWN_TIMEOUT` (default 10s).

`GET /jobs` and `GET /jobs/{id}` require `jobs:read`. `POST /jobs/{id}/cancel` requires `jobs:write`. Canceling a queued job stops it. Canceling a running job cancels its context and returns 202.
