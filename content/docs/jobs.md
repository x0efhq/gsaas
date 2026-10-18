---
title: Jobs
weight: -12
---

# Jobs

Code: `jobs/`, `platform/jobs/`, the job queue adapter in `adapters/`, `cmd/worker/`

Jobs run slow or retryable work outside the request, in a separate worker process. They are stored in Postgres, so they survive restarts and need no Redis.

**What you get**

- **Safe enqueue.** A job enqueued inside a database transaction exists only if the transaction commits.
- **Retries.** A failed job is retried with growing delays. Return `jobs.ErrPermanent` to stop retrying.
- **No duplicates.** A job with the same name, organization and idempotency key isn't queued twice.
- **Jobs API.** List, inspect and cancel your organization's jobs over HTTP.
- **Test queue.** `jobs.NewMem` records jobs in memory, so tests need no worker.

## Running the worker

```bash
make migrate
go run ./cmd/worker
```

`make migrate` creates the queue tables. The worker runs alongside the API server, in its own process.

> [!WARNING]
> The worker must be running, or the [built-in jobs](#built-in-jobs) never run.

## Built-in jobs

| Job | What it does | When it runs | Without the worker |
| --- | --- | --- | --- |
| `billing.process_webhook` | Applies a stored Stripe webhook event | When a Stripe webhook arrives | Subscriptions and plans don't update |
| `billing.cancel_subscription` | Cancels the subscription with the provider | When an organization with a subscription is deleted | The subscription keeps running at the provider |
| `webhooks.deliver` | Sends one event to one customer endpoint | When a subscribed event is published | Outbound webhooks are never delivered |
| `identity.expire_sessions` | Removes expired refresh tokens and invites | Every 15 minutes, and when the worker starts | Expired tokens and invites pile up |
| `projects.apply` | Sample job | When a project is created | The sample job never runs |

Emails don't use the job queue. Event handlers send them directly.

## Adding a job

1. In the owning module, export a job name constant and a method `(ctx, payload []byte) error`.
2. Enqueue it through the injected `jobs.Queue`.
3. Add a `jobs.Job` with the constant and the method to the list in `jobs()` in `app/app.go`. `RunWorker` runs that list.

The sample project job, enqueued in `projects/service.go`:

```go
const ApplyJob = "projects.apply"

if _, err := s.queue.Enqueue(ctx, p.OrgID, ApplyJob, body, jobs.Opts{MaxAttempts: 3}); err != nil {
	return Project{}, fmt.Errorf("projects.Create: %w", err)
}
```

And listed in `jobs()` in `app/app.go`:

```go
{Name: projects.ApplyJob, Handle: a.projects.ApplyPayload},
```

A job whose name isn't in the list is canceled, not retried.

## Scheduled jobs

A scheduled job runs when the worker starts, then again at a fixed interval. It is a job in the same list in `jobs()` in `app/app.go`, with its interval in `Every`; a job without `Every` runs only when enqueued:

```go
func (a *App) jobs() []jobs.Job {
	return []jobs.Job{
		{
			Name: identity.ExpireSessionsJob,
			Handle: func(ctx context.Context, _ []byte) error {
				return errors.Join(a.identity.ExpireRefresh(ctx), a.org.ExpireInvites(ctx))
			},
			Every: 15 * time.Minute,
		},
		{Name: projects.ApplyJob, Handle: a.projects.ApplyPayload},
		// ...
	}
}
```

To add one, add the job as in [Adding a job](#adding-a-job) and set `Every`. You don't need to enqueue it yourself. To change how often a job runs, change its `Every`.

- **Fails fast.** The worker refuses to start if two jobs share a name, a job has no `Handle`, or `Every` is negative.
- **Once per interval.** With several workers running, each scheduled job still runs once per interval, not once per worker. The job queue picks one worker to schedule it.
- **System job.** Scheduled jobs have no organization and no payload, so the handler works across all organizations.

## Behavior

- **Transactional enqueue.** Jobs enqueued inside a database transaction exist only if it commits, so a job never runs for a write that was rolled back. `billing` uses this to store a webhook event and its job together.
- **Payload.** The payload is raw bytes. Built-in jobs encode it as JSON or a plain ID string.
- **Organization.** The org argument to `Enqueue` decides which organization's jobs API shows the job. A job enqueued with `uuid.Nil` is a system job and isn't listed. `billing.process_webhook` and `identity.expire_sessions` are system jobs.
- **Retries.** A handler that returns an error is retried. The default is 25 attempts, unless `jobs.Opts{MaxAttempts: ...}` sets fewer. The delay grows with each attempt (about attempt⁴ seconds, plus some randomness).
- **Failed jobs.** After the last attempt the job's status becomes `failed`. Once any attempt fails, the `error` field of `GET /jobs/{id}` says so, without the error text, which can hold internal detail. The real error is in the worker log.
- **Permanent errors.** Wrap `jobs.ErrPermanent` to stop retries, for input that will never succeed. The job ends as `canceled`, not `failed`.

```go
return fmt.Errorf("bad payload: %w", jobs.ErrPermanent)
```

- **Honor `ctx`.** Stop work and return when `ctx` is canceled. That happens on cancel, on shutdown, and after the per-job timeout of 1 minute. On shutdown, running jobs get `WORKER_SHUTDOWN_TIMEOUT` (default 10 seconds) to finish.
- **Idempotency.** Handlers must be idempotent: running a job twice must have the same effect as once, because a retry can repeat work. `jobs.Opts{IdempotencyKey: ...}` also prevents enqueuing the same job twice; `webhooks.deliver` uses one per event and endpoint.

## Jobs API

| Route | Permission |
| --- | --- |
| `GET /jobs` | `jobs:read` (member and up) |
| `GET /jobs/{id}` | `jobs:read` (member and up) |
| `POST /jobs/{id}/cancel` | `jobs:write` (admin and up) |

The routes are scoped to an organization. System jobs, enqueued without an organization, aren't listed.

A job's `status` is one of `queued`, `running`, `succeeded`, `failed` or `canceled`. Waiting and retrying jobs show as `queued`.

Canceling a queued job stops it at once. Canceling a running job cancels its `ctx`; the response is `202` and may still show `running` until the handler returns.

## Testing

In tests, `jobs.NewMem` records enqueues instead of running them, so you can assert a job was queued without a worker.
