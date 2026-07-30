#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! "$1" =~ ^sha-[0-9a-f]{7}$ ]]; then
  echo "Usage: $0 sha-1234abc" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
compose_file="${repo_root}/compose.yaml"
new_tag="$1"

TAG="$new_tag" COMPOSE_FILE="$compose_file" ruby <<'RUBY'
path = ENV.fetch("COMPOSE_FILE")
tag = ENV.fetch("TAG")
content = File.read(path)
pattern = /(\$\{BUZZ_IMAGE_TAG:-)sha-[0-9a-f]{7}(\})/
matches = content.scan(pattern).length
abort "Expected exactly one Buzz image default, found #{matches}" unless matches == 1
File.write(path, content.sub(pattern, "\\1#{tag}\\2"))
RUBY

printf 'Set Buzz relay image to %s\n' "$new_tag"

