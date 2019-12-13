#!/bin/sh

_RANGES_URL="https://ip-ranges.amazonaws.com/ip-ranges.json"
CURLCMD="curl"

_sep=""
echo "[$(basename "$0")] Fetching Amazon AWS IPv4 ranges..."
printf "[" > amazonaws.json
while read -r _range; do
    _rng=$(printf "%s" "${_range}" | sed -E 's:^.*ip_prefix"\: "(.*)".*$:\1:')
    printf "%s\n  \"%s\"" "${_sep}" "${_rng}" >> amazonaws.json
    _sep=","
done <<DONE
$(${CURLCMD} -sSL ${_RANGES_URL} | grep ip_prefix)
DONE
printf "\n]" >> amazonaws.json
echo "[$(basename "$0")] Fetched Amazon AWS IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < amazonaws.json)"

exit 0
