#!/bin/bash

if [ -z "$1" ]; then
  echo "WARNING!! WEBHOOK_URL environment variable empty" >&2 && exit
fi

COMMITTER_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$CI_COMMIT_SHA" --pretty="%s")"
TIMESTAMP=$(date -u +%FT%TZ)
WEBHOOK_DATA='{
  "username": "",
  "content": "'$COMMIT_SUBJECT' commit: '"[$CI_COMMIT_SHORT_SHA](${CI_PROJECT_URL}/commit/${CI_COMMIT_SHA})"', branch: '"[$CI_COMMIT_REF_NAME](${CI_PROJECT_URL}/tree/${CI_COMMIT_REF_NAME})"'"
}'

curl --progress-bar -A "GitLabCI-Webhook" -H "Content-Type: application/json" -H "X-Author: y0m#7248" -d "$WEBHOOK_DATA" "$1"
