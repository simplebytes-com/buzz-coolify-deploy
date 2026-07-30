#!/usr/bin/env bash
set -euo pipefail

upstream_repo="${BUZZ_UPSTREAM_REPO:-block/buzz}"
workflow="${BUZZ_UPSTREAM_WORKFLOW:-docker.yml}"

head_sha="$(
  gh api \
    "repos/${upstream_repo}/actions/workflows/${workflow}/runs?branch=main&status=success&event=push&per_page=1" \
    --jq '.workflow_runs[0].head_sha'
)"

if [[ ! "$head_sha" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Could not resolve a successful upstream Buzz image build." >&2
  exit 1
fi

printf 'sha-%s\n' "${head_sha:0:7}"

