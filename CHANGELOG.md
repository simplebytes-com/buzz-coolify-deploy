# Changelog

## 2026-07-30

- Added a Git-backed Coolify Compose deployment for Buzz Relay.
- Pinned Buzz to the latest successful immutable upstream relay image,
  `sha-63496cc`.
- Added the Buzz Desktop CORS fix for macOS, Windows, and Linux Tauri origins.
- Added first-run ownership initialization for the persistent Git volume.
- Replaced the invalid `curl` relay healthcheck with the upstream Bash
  `/dev/tcp` readiness probe.
- Kept all state in named volumes and all secrets outside Git.

