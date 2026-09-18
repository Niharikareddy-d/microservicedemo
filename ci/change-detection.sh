#!/bin/bash

set -euo pipefail

DEPLOYABLE_SERVICES=(
    "gateway"
    "auth"
    "user"
    "admin"
    "employee"
    "customer"
    "hr"
    "task"
)

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

OUTPUT_FILE="${WORKSPACE:-$(pwd)}/ci/changed-services.txt"

rm -f "$OUTPUT_FILE"
touch "$OUTPUT_FILE"

if [[ -n "${GIT_PREVIOUS_SUCCESSFUL_COMMIT:-}" ]]; then
    BASE_COMMIT="$GIT_PREVIOUS_SUCCESSFUL_COMMIT"
elif git rev-parse HEAD~1 >/dev/null 2>&1; then
    BASE_COMMIT="$(git rev-parse HEAD~1)"
else
    BASE_COMMIT="$(git rev-list --max-parents=0 HEAD)"
fi

CURRENT_COMMIT="$(git rev-parse HEAD)"

echo "Base commit    : $BASE_COMMIT"
echo "Current commit : $CURRENT_COMMIT"

CHANGED_FILES="$(git diff --name-only "$BASE_COMMIT" "$CURRENT_COMMIT")"

if [[ -z "$CHANGED_FILES" ]]; then
    echo "No file changes detected."
    exit 0
fi

echo "Changed files:"
echo "$CHANGED_FILES"

if echo "$CHANGED_FILES" | grep -Eq '^(pom\.xml|common-library/)'; then
    echo "Shared project change detected."
    printf '%s\n' "${DEPLOYABLE_SERVICES[@]}" > "$OUTPUT_FILE"
else
    for SERVICE in "${DEPLOYABLE_SERVICES[@]}"; do
        SERVICE_DIR="${SERVICE_DIRS[$SERVICE]}"

        if echo "$CHANGED_FILES" | grep -q "^${SERVICE_DIR}/"; then
            echo "$SERVICE" >> "$OUTPUT_FILE"
        fi
    done
fi

sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

echo
echo "Changed services:"
cat "$OUTPUT_FILE"

if [[ ! -s "$OUTPUT_FILE" ]]; then
    echo "No deployable microservice changes detected."
fi
