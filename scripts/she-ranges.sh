#!/bin/sh

_RANGES_URL="http://www.spamhaus.org/drop/edrop.lasso"
CURLCMD="curl"

_sep=""
printf "[" > spamhausedrop.json
while read -r _range; do
    printf "%s\n  \"%s\"" "${_sep}" "${_range}" >> spamhausedrop.json
    _sep=","
done <<DONE
$(${CURLCMD} -sSL ${_RANGES_URL} | sed -E -e 's:;.*::' | grep -v '^ *$')
DONE
printf "\n]" >> spamhausedrop.json

exit 0
