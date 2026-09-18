#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

cd "$PROJECT_ROOT"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services to deploy."
    exit 0
fi

AWS_REGION="${AWS_REGION:-us-east-1}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-enterprise-test-eks}"
BUILD_TAG="${BUILD_NUMBER:?BUILD_NUMBER is not set}"

echo "Updating kubeconfig..."

aws eks update-kubeconfig \
    --name "$EKS_CLUSTER_NAME" \
    --region "$AWS_REGION"

while IFS= read -r SERVICE; do

    case "$SERVICE" in
        gateway)
            HELM_VALUE="services.gateway.tag"
            ;;
        auth)
            HELM_VALUE="services.auth.tag"
            ;;
        user)
            HELM_VALUE="services.user.tag"
            ;;
        admin)
            HELM_VALUE="services.admin.tag"
            ;;
        employee)
            HELM_VALUE="services.employee.tag"
            ;;
        customer)
            HELM_VALUE="services.customer.tag"
            ;;
        hr)
            HELM_VALUE="services.hr.tag"
            ;;
        task)
            HELM_VALUE="services.task.tag"
            ;;
        *)
            echo "ERROR: Unknown service: $SERVICE"
            exit 1
            ;;
    esac

    echo "========================================"
    echo "Helm deployment"
    echo "Service : $SERVICE"
    echo "Tag     : $BUILD_TAG"
    echo "Value   : $HELM_VALUE"
    echo "========================================"

    helm upgrade --install microservices helm \
        --namespace default \
        --wait \
        --timeout 10m \
        --set "${HELM_VALUE}=${BUILD_TAG}"

done < "$CHANGED_SERVICES_FILE"

echo "Helm deployment completed successfully."
