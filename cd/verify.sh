#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services require deployment verification."
    exit 0
fi

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-enterprise-test-eks}"

aws eks update-kubeconfig \
    --name "$EKS_CLUSTER_NAME" \
    --region "$AWS_REGION"

echo "========================================"
echo "Deployment Verification"
echo "========================================"

while IFS= read -r SERVICE; do

    echo
    echo "Service: $SERVICE"
    echo "Namespace: $SERVICE"

    kubectl get deployment "$SERVICE" \
        -n "$SERVICE"

    kubectl get pods \
        -n "$SERVICE" \
        -o wide

    kubectl get service \
        -n "$SERVICE"

    READY_REPLICAS="$(kubectl get deployment "$SERVICE" \
        -n "$SERVICE" \
        -o jsonpath='{.status.readyReplicas}')"

    DESIRED_REPLICAS="$(kubectl get deployment "$SERVICE" \
        -n "$SERVICE" \
        -o jsonpath='{.spec.replicas}')"

    if [[ "${READY_REPLICAS:-0}" != "$DESIRED_REPLICAS" ]]; then
        echo "ERROR: Deployment verification failed for $SERVICE."
        exit 1
    fi

    echo "Verification passed for $SERVICE."

done < "$CHANGED_SERVICES_FILE"

echo
echo "========================================"
echo "All changed services verified successfully."
echo "========================================"
