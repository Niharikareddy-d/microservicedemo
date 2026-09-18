#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services require smoke testing."
    exit 0
fi

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-enterprise-test-eks}"

aws eks update-kubeconfig \
    --name "$EKS_CLUSTER_NAME" \
    --region "$AWS_REGION"

while IFS= read -r SERVICE; do

    echo "========================================"
    echo "Smoke test: $SERVICE"
    echo "========================================"

    NAMESPACE="$SERVICE"

    kubectl rollout status \
        deployment/"$SERVICE" \
        -n "$NAMESPACE" \
        --timeout=5m

    READY_REPLICAS="$(kubectl get deployment "$SERVICE" \
        -n "$NAMESPACE" \
        -o jsonpath='{.status.readyReplicas}')"

    DESIRED_REPLICAS="$(kubectl get deployment "$SERVICE" \
        -n "$NAMESPACE" \
        -o jsonpath='{.spec.replicas}')"

    if [[ "${READY_REPLICAS:-0}" != "$DESIRED_REPLICAS" ]]; then
        echo "ERROR: $SERVICE is not fully ready."
        exit 1
    fi

    echo "$SERVICE is healthy."

done < "$CHANGED_SERVICES_FILE"

echo "Smoke tests completed successfully."
