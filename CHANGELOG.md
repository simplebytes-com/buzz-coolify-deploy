# Changelog

## 2026-07-30

- Added a Git-backed Coolify Compose deployment for Buzz Relay.
- Switched Buzz to Block's official moving `main` image with
  `pull_policy: always`, allowing updates through a normal Coolify redeploy.
- Added the Buzz Desktop CORS fix for macOS, Windows, and Linux Tauri origins.
- Added first-run ownership initialization for the persistent Git volume.
- Replaced the invalid `curl` relay healthcheck with the upstream Bash
  `/dev/tcp` readiness probe.
- Kept all state in named volumes and all secrets outside Git.
- Removed GitHub Actions update automation so deployment and updates do not
  depend on Actions minutes or organization workflow-write permissions.
- Renamed the Compose file to `/docker-compose.yaml`, matching Coolify's
  default Git Compose location.
- Deployed the stack to the Nutrified Coolify production environment at
  `buzz.nutrified.pl`, with DNS-only Cloudflare routing, managed TLS, and
  persistent production storage.
- Enabled the Cloudflare proxy for `buzz.nutrified.pl`, excluded the relay from
  the zone-wide website redirect, and enforced per-hostname Strict TLS to the
  Coolify origin while preserving WebSocket and Buzz Desktop CORS traffic.
- Created a dedicated private Cloudflare R2 bucket for Buzz media and object
  storage.
- Replaced the in-stack MinIO dependency with configurable external
  S3-compatible storage, defaulting to Cloudflare R2's `auto` signing region
  and path-style addressing.
