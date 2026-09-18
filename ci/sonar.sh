#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGED_SERVICES_FILE="${PROJECT_ROOT}/ci/changed-services.txt"

cd "$PROJECT_ROOT"

if [[ ! -s "$CHANGED_SERVICES_FILE" ]]; then
    echo "No changed services for SonarQube analysis."
    exit 0
fi

echo "Running SonarQube analysis for changed services..."

mvn \
  org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
  -Dsonar.projectKey=microservicedemo \
  -Dsonar.projectName=microservicedemo

echo "SonarQube analysis completed."
