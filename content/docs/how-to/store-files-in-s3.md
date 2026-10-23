---
title: How to store files in S3
weight: 12
---

# How to store files in S3

Move file storage from the local disk to an S3-compatible store: AWS S3, Cloudflare R2, Supabase Storage, or MinIO. The variables are listed on the [Configuration]({{< relref "configuration" >}}) page.

The default driver, `disk`, keeps files in `STORAGE_DIR` on the API host. The disk driver works for one server with a persistent volume that the API and the worker both mount. Use S3 when the API and the worker run on separate machines, when you run more than one API instance, or when the host has no persistent disk. Fly.io, Render, and Railway are in that group.

Before you start, create two buckets in the store, one for public files and one for private files, and an access key that can read, write, list, and delete objects in both.

1. Set the driver:

   ```sh
   STORAGE_DRIVER=s3
   ```

2. Set the access key:

   ```sh
   S3_ACCESS_KEY_ID=<key id>
   S3_SECRET_ACCESS_KEY=<secret>
   ```

   If you leave both empty, the server uses the AWS default credential chain, such as an instance role.

3. Name the buckets. The defaults are `public` and `private`.

   ```sh
   S3_PUBLIC_BUCKET=<public bucket>
   S3_PRIVATE_BUCKET=<private bucket>
   ```

4. Set the endpoint, region, and public link base for your provider:

   | Provider | `S3_ENDPOINT` | `S3_REGION` | `S3_PUBLIC_URL` |
   | --- | --- | --- | --- |
   | AWS S3 | empty | the bucket region | empty |
   | Cloudflare R2 | `https://<account>.r2.cloudflarestorage.com` | `auto` | the public domain of the public bucket |
   | Supabase Storage | `https://<project>.supabase.co/storage/v1/s3` | the project region | `https://<project>.supabase.co/storage/v1/object/public` |

5. Make the public bucket readable without a signature. Avatar links point straight at it.

6. Allow `PUT` from your client's origin in the bucket's CORS rules if browsers upload directly.

7. Set the same variables on the API and the worker, then restart both. The worker deletes a deleted user's files, so it needs the same store.

8. Check the switch. Call `POST /files/uploads` as a signed-in user. The `upload_url` in the response points at your store, not at `/storage/` on the API.

The API does not copy files between drivers. Existing files stay in `STORAGE_DIR`, and stored keys keep their names. To keep them, copy each file in `STORAGE_DIR/public/` to the public bucket, and each file in `STORAGE_DIR/private/` to the private bucket, under the same key. Copy before you restart. For example, with the AWS CLI (add `--endpoint-url` for R2 or Supabase):

```sh
aws s3 sync ./data/uploads/public s3://<public bucket> --exclude "*.part"
aws s3 sync ./data/uploads/private s3://<private bucket> --exclude "*.part"
```

Once you switch to S3, the API no longer serves `/storage/` routes, and `STORAGE_SIGNING_KEY` has no effect.
