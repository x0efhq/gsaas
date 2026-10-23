---
title: How to accept a file upload
weight: 12
aliases:
  - /docs/files/
  - /docs/services/files/
---

# How to accept a file upload

The client uploads bytes to a presigned URL, not to the JSON API. With the default `disk` driver, that URL is a signed `/storage/` route on the API. With `s3`, the URL points at the bucket. Storage settings are on the [Configuration]({{< relref "configuration" >}}) page. To move to S3, see [How to store files in S3]({{< relref "store-files-in-s3" >}}).

The caller is a signed-in user. An API key receives 403.

1. `POST /files/uploads` with `kind`, `content_type`, and `size` in bytes. A size above `UPLOAD_MAX_BYTES` returns 400. The response is a URL that accepts a body of exactly that size.
2. The client sends the file bytes to that URL with `PUT` and the returned `headers`.
3. `POST /files/confirm` after the upload finishes.
4. `GET /files/download?key=...` returns a presigned download URL. `DELETE /files?key=...` removes the object.

The built-in kind is `avatar`. Add another in `files/kind.go` as a constant and a case in `ParseKind`. An unknown kind is rejected.
