#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

cd "$PROJECT_ROOT"

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services to build."
    exit 0
fi

while IFS= read -r SERVICE; do

    case "$SERVICE" in
        gateway)
            MODULE="gateway-service"
            ;;
        auth)
            MODULE="auth-service"
            ;;
        user)
            MODULE="user-service"
            ;;
        admin)
            MODULE="admin-service"
            ;;
        employee)
            MODULE="employee-service"
            ;;
        customer)
            MODULE="customer-service"
            ;;
        hr)
            MODULE="hr-service"
            ;;
        task)
            MODULE="task-service"
            ;;
        *)
            echo "ERROR: Unknown service: $SERVICE"
            exit 1
            ;;
    esac

    echo "========================================"
    echo "Building: $SERVICE"
    echo "Module  : $MODULE"
    echo "========================================"

    mvn -pl "$MODULE" -am clean package -DskipTests

done < "$CHANGED_SERVICES_FILE"

echo "CI build completed successfully."
