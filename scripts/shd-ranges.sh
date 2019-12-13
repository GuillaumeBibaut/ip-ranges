#!/bin/sh

_RANGES_URL="https://www.spamhaus.org/drop/drop.txt"
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
echo "[$(basename "$0")] Lines count: $(wc -l < spamhausdrop.json)"

exit 0
