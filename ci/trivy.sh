#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

cd "$PROJECT_ROOT"

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services for Trivy scan."
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
    echo "Trivy scan: $SERVICE"
    echo "Image     : $IMAGE_NAME"
    echo "========================================"

    trivy image \
        --severity HIGH,CRITICAL \
        --exit-code 1 \
        --no-progress \
        "$IMAGE_NAME"

done < "$CHANGED_SERVICES_FILE"

echo "Trivy security scan completed successfully."
