#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

if [[ ! -f "$CHANGED_SERVICES_FILE" ]]; then
    echo "ERROR: changed-services.txt not found."
    exit 1
fi

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services. Skipping SonarQube analysis."
    exit 0
fi

cd "$PROJECT_ROOT"

SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-microservicedemo}"
SONAR_PROJECT_NAME="${SONAR_PROJECT_NAME:-microservicedemo}"

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

BINARY_DIRS=""

while IFS= read -r SERVICE; do
    [[ -z "$SERVICE" ]] && continue

    SERVICE_DIR="${SERVICE_DIRS[$SERVICE]:-}"

    if [[ -z "$SERVICE_DIR" ]]; then
        echo "ERROR: Unknown service: $SERVICE"
        exit 1
    fi

    BINARY_DIR="${PROJECT_ROOT}/${SERVICE_DIR}/target/classes"

    if [[ ! -d "$BINARY_DIR" ]]; then
        echo "ERROR: Java binaries not found: $BINARY_DIR"
        exit 1
    fi

    if [[ -n "$BINARY_DIRS" ]]; then
        BINARY_DIRS="${BINARY_DIRS},${BINARY_DIR}"
    else
        BINARY_DIRS="$BINARY_DIR"
    fi

done < "$CHANGED_SERVICES_FILE"

echo "========================================"
echo "SonarQube Analysis"
echo "Project Key  : ${SONAR_PROJECT_KEY}"
echo "Project Name : ${SONAR_PROJECT_NAME}"
echo "Changed Services:"
cat "$CHANGED_SERVICES_FILE"
echo "Java Binaries: ${BINARY_DIRS}"
echo "========================================"

mvn org.sonarsource.scanner.maven:sonar-maven-plugin:5.8.0.7211:sonar \
    -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
    -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
    -Dsonar.java.binaries="${BINARY_DIRS}"

echo "========================================"
echo "SonarQube analysis completed successfully."
echo "========================================"
