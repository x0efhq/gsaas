---
title: How to store files in S3
weight: 62
aliases:
  - /docs/how-to/store-files-in-s3/
---

# How to store files in S3

Use one store. A saved file key exists only in the store that wrote it. See [Why this shape]({{< relref "/docs/getting-started/why-this-shape.md" >}}) for why the switch is an edit in `app.New`. When the API and the worker do not share a disk, switch before you deploy. See the [Deploy]({{< relref "/docs/deploy/" >}}) checklist.

Keep the default disk store for one server whose API and worker share a persistent `STORAGE_DIR`. You change nothing. The API serves files at signed `/storage/` URLs.

Any S3-compatible store works: AWS S3, Cloudflare R2, Supabase Storage, or MinIO. Before you start, create two buckets, one for public files and one for private files, and an access key that can read, write, list, and delete objects in both.

## Change the code

1. In `platform/config/config.go`, move the commented S3 fields into the `Config` struct, and the commented `r.string("S3_...")` lines into the `Load` literal.
2. In `app.New` in `app/app.go`, replace the `storage.NewDisk` call with the commented `storage.NewS3` call, then pass `s3` to `files.New`. Remove the `/storage/` routes, `BodyLimitSkip`, and the `disk` field from `services` and from `app/isolation_test.go`.
3. In `app/openapi.yaml`, delete the `/storage/{visibility}/{kind}/{owner}/{file}` path.
4. In `platform/config/config.go`, delete `StorageDir`, `StorageSigningKey`, `devStorageSigningKey`, and the signing-key check in `Load`. Update `TestLoad_storage` in `platform/config/config_test.go`. Then run `go build ./... && go vet ./... && go test ./...`.

## Set the variables

In `.env.example`, uncomment the `S3_*` lines and drop `STORAGE_DIR` and `STORAGE_SIGNING_KEY`. Drop `STORAGE_DIR` and the uploads volume from the `Dockerfile` and `docker-compose.yaml`. Set the `S3_*` variables on the API and the worker. The worker deletes a deleted user's files, so it needs the same store.

| Variable | Default | Meaning |
| --- | --- | --- |
| `S3_ENDPOINT` | empty | Empty uses AWS. Set it for another S3-compatible store |
| `S3_REGION` | empty | Bucket region. `auto` for R2 |
| `S3_PUBLIC_URL` | empty | Base for public links. Empty builds AWS links |
| `S3_ACCESS_KEY_ID` | empty | Empty with `S3_SECRET_ACCESS_KEY` uses the AWS default credentials, such as an instance role |
| `S3_SECRET_ACCESS_KEY` | empty | Set with `S3_ACCESS_KEY_ID` or not at all |
| `S3_PUBLIC_BUCKET` | `public` | Bucket for public files, such as avatars |
| `S3_PRIVATE_BUCKET` | `private` | Bucket for private files |

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
