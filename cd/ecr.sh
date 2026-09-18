#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services to push to ECR."
    exit 0
fi

BUILD_TAG="${BUILD_NUMBER:-local}"

AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-058233700821}"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Logging in to Amazon ECR..."

aws ecr get-login-password --region "$AWS_REGION" |
    docker login \
        --username AWS \
        --password-stdin "$ECR_REGISTRY"

while IFS= read -r SERVICE; do

    LOCAL_IMAGE="microservicedemo-${SERVICE}:${BUILD_TAG}"
    ECR_IMAGE="${ECR_REGISTRY}/terraform-platform-test-${SERVICE}:${BUILD_TAG}"

    echo "========================================"
    echo "ECR push   : $SERVICE"
    echo "Image      : $ECR_IMAGE"
    echo "========================================"

    docker tag "$LOCAL_IMAGE" "$ECR_IMAGE"
    docker push "$ECR_IMAGE"

done < "$CHANGED_SERVICES_FILE"

echo "ECR image push completed."
