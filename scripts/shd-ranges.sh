#!/bin/sh

_RANGES_URL="http://www.spamhaus.org/drop/drop.lasso"
CURLCMD="curl"

_sep=""
echo "[$(basename "$0")] Fetching SpamHaus DROP IPv4 ranges..."
printf "[" > spamhausdrop.json
while read -r _range; do
    printf "%s\n  \"%s\"" "${_sep}" "${_range}" >> spamhausdrop.json
    _sep=","
done <<DONE
$(${CURLCMD} -sSL ${_RANGES_URL} | sed -E -e 's:;.*::' | grep -v '^ *$')
DONE
printf "\n]" >> spamhausdrop.json
echo "[$(basename "$0")] Fetched SpamHaus DROP IPv4 ranges."

exit 0
