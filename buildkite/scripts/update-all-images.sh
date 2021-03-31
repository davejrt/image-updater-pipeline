#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -exuo pipefail

./install-srcimg.sh

# setup auth token for gcr
# shellcheck disable=SC2034  # Unused variables read by srcimage
IMAGE_FETCH_TOKEN=$(gcloud auth print-access-token)
export IMAGE_FETCH_TOKEN

IMAGES=(
  cadvisor
  gitserver
  codeinsights-db
  codeintel-db
  frontend
  github-proxy
  grafana
  indexed-searcher
  jaeger-agent
  jaeger-all-in-one minio
  postgres-11.4
  postgres_exporter
  precise-code-intel-worker
  prometheus
  query-runner
  redis-cache
  redis-store
  redis_exporter
  repo-updater
  search-indexer
  searcher
  symbols
  syntax-highlighter
)

FILES=()
mapfile -t FILES < <(fd --extension yaml "Deployment|StatefulSet|DaemonSet")

TAG="${TARGET_COMMIT}"

echo "--- updating all images to ${TAG}"
./parallel_run.sh ./run-srcimg.sh '{1}' '{2}' "${TAG}" ::: "${IMAGES[@]}" ::: "${FILES[@]}"

./touch-update-file.sh
