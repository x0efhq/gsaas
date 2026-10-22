---
title: Run the API and make a first call
weight: 1
---

# Run the API and make a first call

In this tutorial you start the gsaas API on your machine and call it as the local admin user. You finish with that user's JSON body.

You need:

- Go 1.26
- Docker with the Compose plugin
- curl

Run every command from the repository root, in a terminal.

## Create the local settings

Copy the example settings:

```bash
cp .env.example .env
```

Those defaults point the API at Postgres on `localhost:5432` and listen on port `5000`. Leave the file as it is for this tutorial.

## Create the database and the admin user

Start Postgres, apply the migrations, and insert two local users:

```bash
make seed
```

The command finishes after lines like these:

```
level=INFO msg=analytics event=user.registered props=map[user_id:...]
```

You now have a user `admin@local` with password `password`. Running `make seed` again is safe. It does not create a second admin.

## Start the API

In the same terminal, start the server:

```bash
make run
```

Leave this process running. Wait until the log contains:

```
msg=listen addr=[::]:5000
```

The API is now accepting requests on port 5000.

## Check that the API is up

Open a second terminal. From the repository root, run:

```bash
curl localhost:5000/healthz
```

The response is:

```json
{"data":{"ok":true,"version":"dev"},"object":"health"}
```

If curl reports that it cannot connect, the server has not printed `msg=listen addr=[::]:5000` yet. Wait for that line, then run the same curl command again.

## Sign in

Exchange the admin email and password for an access token:

```bash
curl -X POST localhost:5000/auth/signin \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@local","password":"password"}'
```

The response contains `access_token`:

```json
{"data":{"access_token":"eyJ...","expires_at":"...","refresh_token":"...","user_id":"..."},"object":"token"}
```

Copy the `access_token` value. The next command sends it back.

## Call the API as that user

Request the signed-in user. Replace `<access_token>` with the value you copied:

```bash
curl localhost:5000/me -H 'Authorization: Bearer <access_token>'
```

The response is the admin user:

```json
{"data":{"id":"...","email":"admin@local","first_name":"Admin","last_name":"Local","is_platform_admin":true},"object":"user"}
```

That call is the end of this tutorial. The server in the first terminal keeps running until you stop it with Ctrl+C.

Other ways to run the same API, including Docker for the API itself, are on the [Quickstart]({{< relref "quickstart" >}}) page.
