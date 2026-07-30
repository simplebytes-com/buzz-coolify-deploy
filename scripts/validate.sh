#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
compose_file="${repo_root}/compose.yaml"
env_file="${repo_root}/.env.example"
portable_compose="$(mktemp "${TMPDIR:-/tmp}/buzz-compose.XXXXXX.yaml")"
trap 'rm -f "$portable_compose"' EXIT

# Coolify consumes and removes exclude_from_hc before invoking Docker Compose.
# Strip that Coolify-only field so stock Compose can validate the remaining
# deployment model exactly as Docker will receive it.
SOURCE="$compose_file" DESTINATION="$portable_compose" ruby <<'RUBY'
require "yaml"

source = ENV.fetch("SOURCE")
destination = ENV.fetch("DESTINATION")
compose = YAML.safe_load(File.read(source), aliases: true)
compose.fetch("services").each_value { |service| service.delete("exclude_from_hc") }
File.write(destination, YAML.dump(compose))
RUBY

docker compose --env-file "$env_file" -f "$portable_compose" config --quiet

grep -q 'tauri://localhost,http://tauri.localhost' "$compose_file"
grep -q 'chown -R 1000:1000 /data/git' "$compose_file"
grep -q '/dev/tcp/127.0.0.1/8080' "$compose_file"
grep -Eq '\$\{BUZZ_IMAGE_TAG:-(main|sha-[0-9a-f]{7})\}' "$compose_file"

if grep -Eq '^networks:' "$compose_file"; then
  echo "Do not define custom networks in a Coolify Compose deployment." >&2
  exit 1
fi

for script in "${repo_root}"/scripts/*.sh; do
  bash -n "$script"
done

if ! git -C "$repo_root" check-ignore -q .env; then
  echo ".env must remain ignored." >&2
  exit 1
fi

echo "Buzz Coolify deployment validation passed."
