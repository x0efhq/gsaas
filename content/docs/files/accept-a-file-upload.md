---
title: Accept a file upload
weight: 61
aliases:
  - /docs/services/files/
  - /docs/how-to/accept-a-file-upload/
---

# Accept a file upload

The client uploads bytes to a presigned URL, not to the JSON API. By default, that URL is a signed `/storage/` route on the API. After you switch to S3, it points at the bucket. Storage settings are on [Configuration]({{< relref "/docs/reference/configuration.md" >}}). To move to S3, see [Store files in S3]({{< relref "store-files-in-s3" >}}).

```
client ─POST /files/uploads─▶ API ─▶ {url, headers}
client ─PUT bytes─▶ url (/storage/... or S3 bucket)
client ─POST /files/confirm─▶ API
```

The caller is a signed-in user. An API key receives 403. Handlers: `files/handlers.go` `Upload`, `Confirm`. Service: `files/service.go` `PresignUpload`.

1. `POST /files/uploads` with `kind`, `content_type`, and `size` in bytes. A size above `UPLOAD_MAX_BYTES` returns 400.

```bash
curl -X POST localhost:5000/files/uploads \
  -H 'Authorization: Bearer <access_token>' \
  -H 'Content-Type: application/json' \
  -d '{"kind":"avatar","content_type":"image/png","size":1024}'
```

The response includes the upload URL and headers the client must send:

```json
{
  "object": "upload",
  "data": {
    "key": "avatar/<user_id>/<file_id>.png",
    "url": "...",
    "upload_url": "...",
    "method": "PUT",
    "headers": {"Content-Type": "image/png"},
    "expires_at": "..."
  }
}
```

2. The client sends the file bytes to that URL with `PUT` and the returned `headers`.

```bash
curl -X PUT '<upload_url>' \
  -H 'Content-Type: image/png' \
  --data-binary @avatar.png
```

3. `POST /files/confirm` after the upload finishes.

```bash
curl -X POST localhost:5000/files/confirm \
  -H 'Authorization: Bearer <access_token>' \
  -H 'Content-Type: application/json' \
  -d '{"kind":"avatar","key":"avatar/<user_id>/<file_id>.png"}'
```

4. `GET /files/download?key=...` returns a presigned download URL. `DELETE /files?key=...` removes the object.

The built-in kind is `avatar`. Add another in `files/kind.go` as a constant next to `KindAvatar` and a matching `case` in `ParseKind`:

```go
// files/kind.go
const KindAvatar = "avatar"

func ParseKind(s string) (string, error) {
	switch s = strings.TrimSpace(s); s {
	case KindAvatar:
		return s, nil
	default:
		return "", ErrInvalidKind
	}
}
```

An unknown kind is rejected.
