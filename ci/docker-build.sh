#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

cd "$PROJECT_ROOT"

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services for Docker build."
    exit 0
fi

BUILD_TAG="${BUILD_NUMBER:-local}"

declare -A SERVICE_DIRS=(
    ["gateway"]="gateway-service"
    ["auth"]="auth-service"
    ["user"]="user-service"
    ["admin"]="admin-service"
    ["employee"]="employee-service"
    ["customer"]="customer-service"
    ["hr"]="hr-service"
    ["task"]="task-service"
)

while IFS= read -r SERVICE; do

    SERVICE_DIR="${SERVICE_DIRS[$SERVICE]:-}"

    if [[ -z "$SERVICE_DIR" ]]; then
        echo "ERROR: Unknown service: $SERVICE"
        exit 1
    fi

    IMAGE_NAME="microservicedemo-${SERVICE}:${BUILD_TAG}"

    echo "========================================"
    echo "Docker build: $SERVICE"
    echo "Directory   : $SERVICE_DIR"
    echo "Image       : $IMAGE_NAME"
    echo "========================================"

    docker build \
        -t "$IMAGE_NAME" \
        -f "${SERVICE_DIR}/Dockerfile" \
        .

done < "$CHANGED_SERVICES_FILE"

echo "Docker build completed successfully."
