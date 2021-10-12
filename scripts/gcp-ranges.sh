#!/bin/sh

_RANGES_URL="https://www.gstatic.com/ipranges/cloud.json"
CURLCMD="curl"

_sep=""
echo "[$(basename "$0")] Fetching Google Cloud Plateform IPv4 ranges..."
printf "[" > googlecloud.json
while read -r _range; do
    _rng=$(printf "%s" "${_range}" | sed -E 's:^.*ipv4Prefix"\: "(.*)".*$:\1:')
    printf "%s\n  \"%s\"" "${_sep}" "${_rng}" >> googlecloud.json
    _sep=","
done <<DONE
$(${CURLCMD} -sSL ${_RANGES_URL} | grep ipv4Prefix)
DONE
printf "\n]" >> googlecloud.json
echo "[$(basename "$0")] Fetched Google Cloud Plateform IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < googlecloud.json)"

exit 0
