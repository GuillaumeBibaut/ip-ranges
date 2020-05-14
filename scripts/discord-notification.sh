#!/bin/bash

if [ -z "$2" ]; then
  echo "WARNING!! WEBHOOK_URL environment variable empty" && exit
fi

echo "[Webhook]: Sending webhook to Discord...";

case $1 in
  "push" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="push"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="Status Unknown"
    ;;
esac

COMMITTER_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$CI_COMMIT_SHA" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "$CI_COMMIT_SHA" --pretty="%s")"


TIMESTAMP=$(date --utc +%FT%TZ)
WEBHOOK_DATA='{
  "username": "",
  "avatar_url": "https://gitlab.com/favicon.png",
  "embeds": [ {
    "color": '$EMBED_COLOR',
    "author": {
      "name": "'"$COMMITTER_NAME"'",
      "url": "'"$CI_PIPELINE_URL"'",
      "icon_url": "https://gitlab.com/favicon.png"
    },
    "title": "'"$COMMIT_SUBJECT"'",
    "url": "'"$URL"'",
    "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
    "fields": [
      {
        "name": "Commit",
        "value": "'"[\`$CI_COMMIT_SHORT_SHA\`]($CI_PROJECT_URL/commit/$CI_COMMIT_SHA)"'",
        "inline": true
      },
      {
        "name": "Branch",
        "value": "'"[\`$CI_COMMIT_REF_NAME\`]($CI_PROJECT_URL/tree/$CI_COMMIT_REF_NAME)"'",
        "inline": true
      }
    ],
    "timestamp": "'"$TIMESTAMP"'"
  } ]
}'

(curl --fail --progress-bar -A "GitLabCI-Webhook" -H "Content-Type:application/json" -H "X-Author:y0m#7248" -d "$WEBHOOK_DATA" "$2" \
  && echo "[Webhook]: Successfully sent the webhook.") || echo "[Webhook]: Unable to send webhook."
