---
title: How to accept a file upload
weight: 12
aliases:
  - /docs/files/
  - /docs/services/files/
---

# How to accept a file upload

The client uploads bytes to storage, not to the API. The API returns a presigned URL. Storage settings are on the [Configuration]({{< relref "configuration" >}}) page. With `S3_ACCESS_KEY_ID` empty, these routes have no storage.

The caller is a signed-in user. An API key receives 403.

1. `POST /files/uploads` with `kind`, `content_type`, and `size` in bytes. A size above `UPLOAD_MAX_BYTES` returns 400. The response is a URL that accepts a body of exactly that size.
2. The client sends the file bytes to that URL.
3. `POST /files/confirm` after the upload finishes.
4. `GET /files/download?key=...` returns a presigned download URL. `DELETE /files?key=...` removes the object.

The built-in kind is `avatar`. Add another in `files/kind.go` as a constant and a case in `ParseKind`. An unknown kind is rejected.
