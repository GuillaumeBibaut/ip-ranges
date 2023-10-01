#!/bin/sh

set -x
set -e

_RANGES_URL="https://www.gstatic.com/ipranges/cloud.json"
CURLCMD="curl"
JQCMD="jq"

echo "[$(basename "$0")] Fetching Google Cloud Plateform IPv4 ranges..."

${CURLCMD} -sSL ${_RANGES_URL} | ${JQCMD}  '[.prefixes[] | select(.ipv4Prefix).ipv4Prefix]' >"googlecloud.json"

echo "[$(basename "$0")] Fetched Google Cloud Plateform IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < googlecloud.json)"

exit 0