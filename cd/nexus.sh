#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services to push to Nexus."
    exit 0
fi

BUILD_TAG="${BUILD_NUMBER:-local}"

NEXUS_REGISTRY="${NEXUS_REGISTRY:?NEXUS_REGISTRY is not set}"
NEXUS_USERNAME="${NEXUS_USERNAME:?NEXUS_USERNAME is not set}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:?NEXUS_PASSWORD is not set}"

echo "$NEXUS_PASSWORD" | docker login "$NEXUS_REGISTRY" \
    --username "$NEXUS_USERNAME" \
    --password-stdin

while IFS= read -r SERVICE; do

    LOCAL_IMAGE="microservicedemo-${SERVICE}:${BUILD_TAG}"
    NEXUS_IMAGE="${NEXUS_REGISTRY}/microservicedemo-${SERVICE}:${BUILD_TAG}"

    echo "========================================"
    echo "Nexus push : $SERVICE"
    echo "Image      : $NEXUS_IMAGE"
    echo "========================================"

    docker tag "$LOCAL_IMAGE" "$NEXUS_IMAGE"
    docker push "$NEXUS_IMAGE"

done < "$CHANGED_SERVICES_FILE"

echo "Nexus image push completed."
