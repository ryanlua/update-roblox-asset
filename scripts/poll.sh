#!/usr/bin/env bash

set -euo pipefail

: "${API_KEY:?Missing API_KEY}"
: "${OPERATION_ID:?Missing OPERATION_ID}"

max_retries=10
retry_delay=1

for attempt in $(seq 1 "$max_retries"); do
  operation_response="$(curl --silent --show-error --location --request GET \
    "https://apis.roblox.com/assets/v1/operations/${OPERATION_ID}" \
    --header "x-api-key: ${API_KEY}")"

  operation_done="$(jq -r '.done // false' <<<"$operation_response")"
  if [[ "$operation_done" == "true" ]]; then
    operation_error_code="$(jq -r '.error.code // empty' <<<"$operation_response")"
    if [[ -n "$operation_error_code" ]]; then
      operation_error_message="$(jq -r '.error.message // "Roblox asset update failed."' <<<"$operation_response")"
      echo "Roblox asset update failed: ${operation_error_code}: ${operation_error_message}" >&2
      echo "$operation_response" >&2
      exit 1
    fi

    echo "Roblox asset update completed."
    exit 0
  fi

  if [[ "$attempt" -eq "$max_retries" ]]; then
    echo "Timed out waiting for Roblox asset update operation ${OPERATION_ID}." >&2
    echo "$operation_response" >&2
    exit 1
  fi

  sleep "$retry_delay"
  retry_delay=$((retry_delay * 2))
done