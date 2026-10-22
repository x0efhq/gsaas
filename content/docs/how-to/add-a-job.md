---
title: How to add a job
weight: 4
---

# How to add a job

Put slow, retryable, or status-visible work on the job queue. The API process does not run the queue. A separate worker process does.

1. In the module that owns the work, export the job name and a method with the signature `(ctx context.Context, payload []byte) error`.
2. Enqueue it with the injected `worker.Queue`. Pass the organization id. Use `uuid.Nil` for a system job that has no organization.
3. Add a `worker.Job` to the slice returned by `jobs()` in `app/app.go`. Set `Name` to the constant and `Handle` to the method. A name that is not in that list is canceled, not retried.
4. Start the worker next to the API:

```bash
go run ./cmd/worker
```

The worker runs until you stop it. On start it also runs any job whose `Every` interval is set, then waits.

Return `worker.ErrPermanent` from the handler, wrapped with the method name, when the payload will never succeed. Any other error is retried. Honor `ctx`.

The sample is `projects.ApplyJob`, enqueued from `projects/service.go` and registered in `jobs()`. Built-in job names and what fails when the worker is down are on the [Jobs]({{< relref "jobs" >}}) page.
