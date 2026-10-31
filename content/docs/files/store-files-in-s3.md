---
title: Store files in S3
weight: 62
aliases:
  - /docs/how-to/store-files-in-s3/
---

# Store files in S3

Use one store. A saved file key exists only in the store that wrote it. See [Why the code is laid out this way]({{< relref "/docs/getting-started/why-this-shape.md" >}}) for why the switch is an edit in `app.New`. When the API and the worker do not share a disk, switch before you deploy. See the [Deploy]({{< relref "/docs/deploy/" >}}) checklist.

Keep the default disk store for one server whose API and worker share a persistent `STORAGE_DIR`. You change nothing. The API serves files at signed `/storage/` URLs.

Any S3-compatible store works: AWS S3, Cloudflare R2, Supabase Storage, or MinIO. Before you start, create two buckets, one for public files and one for private files, and an access key that can read, write, list, and delete objects in both.

## Change the code

1. In `platform/config/config.go`, move the commented S3 fields into the `Config` struct, and the commented `r.string("S3_...")` lines into the `Load` literal.

Before (commented block after `Config`):

```go
// S3, add these to Config and to the Load literal when switching to S3.
//
//	S3Endpoint        string
//	S3Region          string
//	S3PublicURL       string
//	S3AccessKeyID     string
//	S3SecretAccessKey string
//	S3PublicBucket    string
//	S3PrivateBucket   string
//
//	S3Endpoint:        r.string("S3_ENDPOINT", ""),
//	S3Region:          r.string("S3_REGION", ""),
//	S3PublicURL:       r.string("S3_PUBLIC_URL", ""),
//	S3AccessKeyID:     r.string("S3_ACCESS_KEY_ID", ""),
//	S3SecretAccessKey: r.string("S3_SECRET_ACCESS_KEY", ""),
//	S3PublicBucket:    r.string("S3_PUBLIC_BUCKET", "public"),
//	S3PrivateBucket:   r.string("S3_PRIVATE_BUCKET", "private"),
```

After: those fields live on `Config`, and those `r.string` lines sit in the `Load` literal next to the other settings.

2. In `app.New` in `app/app.go`, replace the `storage.NewDisk` call with `storage.NewS3`, then pass that store to `files.New`:

Before:

```go
disk, err := storage.NewDisk(storage.DiskOptions{
	Dir:        cfg.StorageDir,
	BaseURL:    cfg.AppBaseURL,
	SigningKey: cfg.StorageSigningKey,
	MaxBytes:   cfg.UploadMaxBytes,
	Clock:      clk,
})
if err != nil {
	return nil, err
}
filesSvc := files.New(disk, jobQueue, clk, files.Config{Expires: cfg.FileExpires, MaxBytes: cfg.UploadMaxBytes})
```

After:

```go
s3, err := storage.NewS3(ctx, storage.Options{
	Region:          cfg.S3Region,
	Endpoint:        cfg.S3Endpoint,
	PublicURL:       cfg.S3PublicURL,
	AccessKeyID:     cfg.S3AccessKeyID,
	SecretAccessKey: cfg.S3SecretAccessKey,
	PublicBucket:    cfg.S3PublicBucket,
	PrivateBucket:   cfg.S3PrivateBucket,
})
if err != nil {
	return nil, err
}
filesSvc := files.New(s3, jobQueue, clk, files.Config{Expires: cfg.FileExpires, MaxBytes: cfg.UploadMaxBytes})
```

3. In `router` in the same file, delete the two `/storage/` routes and the `BodyLimitSkip` option. Remove the `disk` field from `services` and from the `services` literal in `app.New`, and from the test fixture in `app/isolation_test.go`.

4. In `app/openapi.yaml`, delete the `/storage/{visibility}/{kind}/{owner}/{file}` path. The OpenAPI test does not catch a documented path that has no route.

5. In `platform/config/config.go`, delete `StorageDir`, `StorageSigningKey`, `devStorageSigningKey`, and the signing-key check in `Load`. If you keep the check, production still refuses to start without a 32-byte key.

Before (fields still on `Config`):

```go
StorageDir            string // files live here; the API serves them at /storage/
StorageSigningKey     string // signs /storage/ URLs
```

After: those two fields are gone, and `Load` no longer reads `STORAGE_DIR` or `STORAGE_SIGNING_KEY`.

6. Update `TestLoad_storage` in `platform/config/config_test.go`. `TestStorage_s3` runs the shared suite against a real bucket when `TEST_S3_ENDPOINT` is set. Then run `go build ./... && go vet ./... && go test ./...`.

## Set the variables

In `.env.example`, uncomment the `S3_*` lines and drop `STORAGE_DIR` and `STORAGE_SIGNING_KEY`. Drop `STORAGE_DIR` and the uploads volume from the `Dockerfile` and `docker-compose.yaml`. Set the `S3_*` variables on the API and the worker. The worker deletes a deleted user's files, so it needs the same store.

| Variable | Example |
| --- | --- |
| `S3_ENDPOINT` | empty for AWS; `https://<account>.r2.cloudflarestorage.com` for R2 |
| `S3_REGION` | bucket region; `auto` for R2 |
| `S3_PUBLIC_URL` | empty for AWS links; public domain of the public bucket for R2 |
| `S3_ACCESS_KEY_ID` | access key, or empty with `S3_SECRET_ACCESS_KEY` for the AWS default credentials |
| `S3_SECRET_ACCESS_KEY` | secret key, or empty with the access key unset |
| `S3_PUBLIC_BUCKET` | `public` |
| `S3_PRIVATE_BUCKET` | `private` |

| Provider | `S3_ENDPOINT` | `S3_REGION` | `S3_PUBLIC_URL` |
| --- | --- | --- | --- |
| AWS S3 | empty | the bucket region | empty |
| Cloudflare R2 | `https://<account>.r2.cloudflarestorage.com` | `auto` | the public domain of the public bucket |
| Supabase Storage | `https://<project>.supabase.co/storage/v1/s3` | the project region | `https://<project>.supabase.co/storage/v1/object/public` |

## Configure the buckets

1. Make the public bucket readable without a signature. Avatar links point straight at it.
2. If browsers upload directly, allow `PUT` from your client's origin in the bucket's CORS rules.

## Check the switch

Restart the API and the worker. Call `POST /files/uploads` as a signed-in user. The `upload_url` in the response points at your store, not at `/storage/` on the API.

## Copy existing files

Files already in `STORAGE_DIR` stay there, and stored keys keep their names. To keep them, copy each file in `STORAGE_DIR/public/` to the public bucket and each file in `STORAGE_DIR/private/` to the private bucket, under the same key. Copy before you restart:

```sh
aws s3 sync ./data/uploads/public s3://<public bucket> --exclude "*.part"
aws s3 sync ./data/uploads/private s3://<private bucket> --exclude "*.part"
```

Add `--endpoint-url` for R2 or Supabase.
