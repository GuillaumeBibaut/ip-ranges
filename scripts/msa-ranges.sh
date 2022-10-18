#!/bin/sh

_INITIALURL="https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"
_DLURL=$(curl -sSL "${_INITIALURL}" | grep "ServiceTags_Public_" | tail -n1 | sed -E 's@^.*(https://download\.microsoft\.com/download/[^"]+/ServiceTags_Public_[^"]+.json)".*$@\1@')

_sep=""
echo "[$(basename "$0")] Fetching Microsoft Azure Cloud IPv4 ranges..."
printf "[" > msazure.json

while read -r _range; do
    if [ -z "${_range}" ]; then
        break
    fi
    printf "%s\n  \"%s\"" "${_sep}" "${_range}" >> msazure.json
    _sep=","
done <<DONE
$(curl -sSL "${_DLURL}" | jq -r '.values[] | select(.properties.platform == "Azure") | .properties.addressPrefixes[]' | grep -E '^(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}.*$')
DONE

printf "\n]" >> msazure.json
echo "[$(basename "$0")] Fetched Microsoft Azure Cloud IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < msazure.json)"

exit 0
