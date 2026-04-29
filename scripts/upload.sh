#!/usr/bin/env bash

set -euo pipefail

: "${API_KEY:?Missing API_KEY}"
: "${ASSET_ID:?Missing ASSET_ID}"
: "${FILE_PATH:?Missing FILE_PATH}"

display_name="${DISPLAY_NAME:-}"
description="${DESCRIPTION:-}"

if [[ ! -f "$FILE_PATH" ]]; then
  echo "Asset file not found: $FILE_PATH" >&2
  exit 1
fi

request_payload="$(jq -nc \
  --arg assetId "$ASSET_ID" \
  --arg displayName "$display_name" \
  --arg description "$description" \
  '(
    {assetId: $assetId}
    + (if $displayName != "" then {displayName: $displayName} else {} end)
    + (if $description != "" then {description: $description} else {} end)
  )')"

upload_response="$(curl --silent --show-error --location --request PATCH \
  "https://apis.roblox.com/assets/v1/assets/${ASSET_ID}" \
  --header "x-api-key: ${API_KEY}" \
  --form-string "request=${request_payload}" \
  --form "fileContent=@${FILE_PATH};type=model/x-rbxm")"

operation_path="$(jq -r '.path // empty' <<<"$upload_response")"
if [[ -z "$operation_path" ]]; then
  operation_id="$(jq -r '.operationId // empty' <<<"$upload_response")"
  if [[ -z "$operation_id" ]]; then
    echo "Unexpected Roblox upload response:" >&2
    echo "$upload_response" >&2
    exit 1
  fi

  operation_path="operations/${operation_id}"
fi

operation_id="${operation_path##*/}"

echo "operation-id=$operation_id" >> "$GITHUB_OUTPUT"