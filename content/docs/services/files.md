---
title: File uploads
weight: -11
aliases:
  - /docs/files/
---

# File uploads

Code: `files/`, `adapters/storage/`

Files go straight from the client to S3-compatible storage through presigned URLs, so the API never handles file bytes. One adapter covers AWS S3, Cloudflare R2, Supabase Storage and other S3-compatible services. They differ only in settings.

## Setup

Set `S3_ENDPOINT`, `S3_REGION`, `S3_ACCESS_KEY_ID` and `S3_SECRET_ACCESS_KEY`. Buckets default to `public` and `private` (`S3_PUBLIC_BUCKET`, `S3_PRIVATE_BUCKET`). `S3_PUBLIC_URL` sets the base URL for public files, and `FILE_EXPIRES` sets how long presigned URLs stay valid (default 15 minutes).

## Routes

The routes need a signed-in user.

| Route | Purpose |
| --- | --- |
| `POST /files/uploads` | Get a presigned upload URL |
| `POST /files/confirm` | Confirm the upload finished |
| `GET /files/download?key=...` | Get a presigned download URL |
| `DELETE /files?key=...` | Delete a file |

`POST /files/uploads` takes `kind`, `content_type` and `size` (bytes). Sizes above `UPLOAD_MAX_BYTES` (default 10485760, 10 MiB) are rejected with a 400, and the presigned URL only accepts a body of exactly that size.

Each file has a kind. The built-in kind is `avatar`. Add kinds in `files/kind.go`, as a constant and a case in `ParseKind`:

```go
const (
	KindAvatar Kind = "avatar"
)

func ParseKind(s string) (Kind, error) {
	switch Kind(strings.TrimSpace(s)) {
	case KindAvatar:
		return Kind(strings.TrimSpace(s)), nil
	default:
		return "", ErrInvalidKind
	}
}
```
