# Buzz Relay on Coolify

This repository deploys Buzz Relay as a Git-backed Docker Compose application
on Coolify. It deliberately does not fork Buzz:

- Buzz runs from Block's published `ghcr.io/block/buzz` image.
- The image is pinned to an immutable `sha-xxxxxxx` tag from a successful
  upstream image build.
- This repository owns only deployment policy and the temporary Coolify fixes.
- Merging a reviewed image update pull request triggers Coolify auto-deploy.

## Included fixes

The stack includes fixes that are not yet available in stable Coolify:

1. `BUZZ_CORS_ORIGINS` includes `tauri://localhost` and
   `http://tauri.localhost`, allowing Buzz Desktop to connect.
2. `buzz-git-init` makes the persistent Git volume writable by Buzz's UID 1000.
3. The Buzz healthcheck uses Bash `/dev/tcp`; the runtime image has no
   `curl` or `wget`.
4. No custom Docker network is defined, so Coolify's proxy always uses the
   correct managed network.

## One-time Coolify setup

1. Push this directory to a GitHub repository.
2. In Coolify, create a **Private Repository (with GitHub App)** resource.
3. Select this repository and choose the **Docker Compose** build pack.
4. Use branch `main`, base directory `/`, and Compose file `/compose.yaml`.
5. Add the variables from `.env.example` in Coolify. Generate new values for
   every `CHANGE_ME` entry and store them only in Coolify. Do not add a
   `BUZZ_IMAGE_TAG` override during normal operation; the reviewed value in
   `compose.yaml` controls updates.
6. Assign `https://YOUR_DOMAIN:3000` to the `buzz` service. The `:3000` tells
   Coolify which internal container port to proxy; the public URL still uses
   normal HTTPS on port 443.
7. Enable **Auto Deploy** in the application's Advanced settings.
8. Deploy, then verify:

   ```bash
   curl -fsS https://YOUR_DOMAIN/_liveness
   curl -fsS https://YOUR_DOMAIN/_readiness
   ```

Do not expose Postgres, Redis, MinIO, port 8080, or port 9102 publicly.

## Generating stable secrets

Generate the values once. Never rotate them during a normal image update:

```bash
openssl rand -hex 32  # BUZZ_RELAY_PRIVATE_KEY
openssl rand -hex 32  # BUZZ_GIT_HOOK_HMAC_SECRET
openssl rand -base64 36 | tr -d '\n'  # POSTGRES_PASSWORD
openssl rand -base64 36 | tr -d '\n'  # REDIS_PASSWORD
openssl rand -hex 16  # BUZZ_S3_ACCESS_KEY
openssl rand -base64 36 | tr -d '\n'  # BUZZ_S3_SECRET_KEY
```

`RELAY_OWNER_PUBKEY` is the owner's 64-character hexadecimal Nostr public key,
not an `npub1...` value and not a private key.

## Updating Buzz

The scheduled workflow checks Block's latest successful `Docker image` workflow
on `main`. If the immutable image tag changed, it opens a pull request updating
`compose.yaml`.

In the deployment repository, enable:

- **Settings → Actions → General → Workflow permissions → Read and write**
- **Allow GitHub Actions to create and approve pull requests**

Review the upstream changes and merge the pull request. Coolify then
automatically redeploys the new image. The persistent volumes and all stable
secrets remain unchanged.

To check immediately, run the **Check for Buzz relay update** workflow manually.

To roll back, revert the image-update commit or restore the previous
`BUZZ_IMAGE_TAG` in Coolify, then redeploy.

## Migration to Coolify's official template

Keep this Git-backed deployment until the official Buzz service reaches stable
Coolify and includes all three fixes above. There is no operational need to
migrate: the Git-backed application provides better version review and rollback
than a server-local service template.

If you do migrate, back up all four named volumes first and preserve the relay
private key, owner public key, HMAC secret, database credentials, Redis
credentials, and S3 credentials.
