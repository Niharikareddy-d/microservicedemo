#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

# --------------------------------------------------
# Validate changed services file
# --------------------------------------------------

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services to push to Nexus."
    exit 0
fi

# --------------------------------------------------
# Build tag
# --------------------------------------------------

BUILD_TAG="${BUILD_NUMBER:-local}"

# --------------------------------------------------
# Nexus configuration
# NEXUS_REGISTRY must be provided by Jenkins
# NEXUS_USERNAME and NEXUS_PASSWORD come from
# Jenkins credential: nexus-docker
# --------------------------------------------------

NEXUS_REGISTRY="${NEXUS_REGISTRY:?ERROR: NEXUS_REGISTRY is not set}"
NEXUS_USERNAME="${NEXUS_USERNAME:?ERROR: NEXUS_USERNAME is not set}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:?ERROR: NEXUS_PASSWORD is not set}"

echo "========================================"
echo "Nexus Docker Registry"
echo "Registry : ${NEXUS_REGISTRY}"
echo "========================================"

# --------------------------------------------------
# Nexus Docker login
# --------------------------------------------------

echo "$NEXUS_PASSWORD" | docker login "$NEXUS_REGISTRY" \
    --username "$NEXUS_USERNAME" \
    --password-stdin

# --------------------------------------------------
# Push only changed services
# --------------------------------------------------

while IFS= read -r SERVICE; do

    # Skip empty lines
    [[ -z "$SERVICE" ]] && continue

    LOCAL_IMAGE="microservicedemo-${SERVICE}:${BUILD_TAG}"
    NEXUS_IMAGE="${NEXUS_REGISTRY}/microservicedemo-${SERVICE}:${BUILD_TAG}"

    echo "========================================"
    echo "Nexus push : ${SERVICE}"
    echo "Local image: ${LOCAL_IMAGE}"
    echo "Nexus image: ${NEXUS_IMAGE}"
    echo "========================================"

    # Tag image for Nexus
    docker tag "$LOCAL_IMAGE" "$NEXUS_IMAGE"

    # Push image to Nexus
    docker push "$NEXUS_IMAGE"

done < "$CHANGED_SERVICES_FILE"

echo "========================================"
echo "Nexus image push completed successfully."
echo "Build tag: ${BUILD_TAG}"
echo "========================================"
