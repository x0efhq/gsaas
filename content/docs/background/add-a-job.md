---
title: How to add a job
weight: 51
aliases:
  - /docs/how-to/add-a-job/
---

# How to add a job

Put slow, retryable, or status-visible work on the job queue. Built-in names, statuses, retries, and `worker.ErrPermanent` are on the [Jobs]({{< relref "/docs/reference/jobs.md" >}}) page.

1. In the module that owns the work, export the job name and a method with the signature `(ctx context.Context, payload []byte) error`.
2. Enqueue it with the injected `worker.Queue`. Pass the organization id. Use `uuid.Nil` for a system job that has no organization.
3. Add a `worker.Job` to the slice returned by `jobs()` in `app/app.go`. Set `Name` to the constant and `Handle` to the method.
4. Start the worker next to the API:

```bash
go run ./cmd/worker
```

The worker runs until you stop it. On start it also runs any job whose `Every` interval is set, then waits.

The sample is `projects.ApplyJob`, enqueued from `projects/service.go` and registered in `jobs()`. Set `Every` on the `worker.Job` to run it on a schedule without enqueueing it. Honor `ctx`.
