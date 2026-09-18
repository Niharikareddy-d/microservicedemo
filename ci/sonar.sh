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
    echo "No changed services. Skipping SonarQube analysis."
    exit 0
fi

echo "Running SonarQube analysis for changed services..."

mvn sonar:sonar \
    -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
    -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
    -Dsonar.java.binaries="*/target/classes"

echo "SonarQube analysis completed successfully."
