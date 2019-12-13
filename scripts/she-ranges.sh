#!/bin/sh

_RANGES_URL="https://www.spamhaus.org/drop/edrop.lasso"
CURLCMD="curl"

_sep=""
echo "[$(basename "$0")] Fetching SpamHaus EDROP IPv4 ranges..."
printf "[" > spamhausedrop.json
while read -r _range; do
    printf "%s\n  \"%s\"" "${_sep}" "${_range}" >> spamhausedrop.json
    _sep=","
done <<DONE
$(${CURLCMD} -sSL ${_RANGES_URL} | sed -E -e 's:;.*::' | grep -v '^ *$')
DONE
printf "\n]" >> spamhausedrop.json
echo "[$(basename "$0")] Fetched SpamHaus EDROP IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < spamhausedrop.json)"

exit 0
