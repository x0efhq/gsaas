---
title: Your first call
weight: 12
aliases:
  - /docs/quickstart/
  - /docs/services/quickstart/
  - /docs/tutorial/first-call/
---

# Your first call

Start the gsaas API on your machine and call it as the local admin user. You finish with that user's JSON body.

You need Go 1.26, Docker with the Compose plugin, and curl. Run every command from the repository root.

## Create the local settings

```bash
cp .env.example .env
```

You should see a new `.env` file. Those defaults point the API at Postgres on `localhost:5432` and listen on port `5000`. Leave the file as it is for this tutorial.

## Create the database and the admin user

```bash
make seed
```

You should see log lines like `level=INFO msg=analytics event=user.registered`. You now have a user `admin@local` with password `password`. Running `make seed` again is safe. It does not create a second admin.

## Start the API

```bash
make run
```

Leave this process running. You should see `msg=listen addr=[::]:5000`. The API accepts requests on port 5000.

## Check that the API is up

In a second terminal, from the repository root:

```bash
curl localhost:5000/healthz
```

You should see:

```json
{"data":{"ok":true,"version":"dev"},"object":"health"}
```

If curl cannot connect, wait for `msg=listen addr=[::]:5000`, then run the same command again.

## Sign in

```bash
curl -X POST localhost:5000/auth/signin \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@local","password":"password"}'
```

You should see a body with `access_token`. Copy that value for the next step.

## Call the API as that user

Replace `<access_token>` with the value you copied:

```bash
curl localhost:5000/me -H 'Authorization: Bearer <access_token>'
```

You should see the admin user, including `"email":"admin@local"` and `"is_platform_admin":true`.

That call ends the tutorial. Stop the server with Ctrl+C. `make stop` stops Postgres and keeps its data.
