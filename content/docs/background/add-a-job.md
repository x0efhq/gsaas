---
title: Run work in the background
weight: 51
aliases:
  - /docs/how-to/add-a-job/
---

# Run work in the background

Put slow, retryable, or status-visible work on the job queue. Built-in names, statuses, retries, and `worker.ErrPermanent` are on the [Jobs]({{< relref "/docs/reference/jobs.md" >}}) page.

```
Service ─Enqueue(orgID, payload)─▶ queue (DB) ─▶ worker ─▶ Handle(ctx, payload)
                                       ▲  retry on error (25x) │ ErrPermanent → canceled
                                       └────────────────────────┘
```

1. In the module that owns the work, export the job name and a method with the signature `(ctx context.Context, payload []byte) error`.

```go
// projects/service.go
const ApplyJob = "projects.apply"

func (s *Service) ApplyPayload(ctx context.Context, payload []byte) error {
	var in applyPayload
	if err := json.Unmarshal(payload, &in); err != nil || in.OrgID == uuid.Nil || in.ID == uuid.Nil {
		return fmt.Errorf("projects.ApplyPayload: %w", worker.ErrPermanent)
	}
	if _, err := s.store.Get(ctx, in.OrgID, in.ID); err != nil {
		if errors.Is(err, ErrNotFound) {
			return nil
		}
		return fmt.Errorf("projects.ApplyPayload: %w", err)
	}
	slog.Info("projects.ApplyPayload", "org_id", in.OrgID, "job", ApplyJob)
	return nil
}
```

2. Enqueue it with the injected `worker.Queue`. Pass the organization id. Use `uuid.Nil` for a system job that has no organization.

```go
// projects/service.go — in Create, after the write
if _, err := s.queue.Enqueue(ctx, p.OrgID, ApplyJob, body, worker.Opts{MaxAttempts: 3}); err != nil {
	return Project{}, fmt.Errorf("projects.Create: %w", err)
}
```

3. Add a `worker.Job` to the `jobList` slice in `app.New` in `app/app.go`. Set `Name` to the constant and `Handle` to the method. Set `Every` to run on a schedule without enqueueing:

```go
// app/app.go — jobList in New
{
	Name: identity.ExpireSessionsJob,
	Handle: func(ctx context.Context, _ []byte) error {
		return errors.Join(idSvc.ExpireRefresh(ctx), orgSvc.ExpireInvites(ctx))
	},
	Every: 15 * time.Minute,
},
{Name: projects.ApplyJob, Handle: projectSvc.ApplyPayload},
```

4. Start the worker next to the API:

```bash
go run ./cmd/worker
```

On start it also runs any job whose `Every` interval is set, then waits. Honor `ctx`.
