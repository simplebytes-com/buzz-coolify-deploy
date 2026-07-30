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
