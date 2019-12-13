#!/bin/sh

_FIRSTLONGPART="https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_"
_INITIALURL="https://www.microsoft.com/EN-US/DOWNLOAD/confirmation.aspx?id=41653"
_DATE=$(curl -sSL "${_INITIALURL}" | grep "PublicIPs_" | tail -n1 | sed -E "s:^.*018E208D-54F8-44CD-AA26-CD7BC9524A8C/PublicIPs_(.*)\.xml.*$:\1:")

_sep=""
echo "[$(basename "$0")] Fetching Microsoft Azure Cloud IPv4 ranges..."
printf "[" > msazure.json
while read -r _range; do
    _rng=$(printf "%s" "${_range}" | sed -E 's:^.*Subnet="(.*)".*$:\1:')
    if [ -z "${_rng}" ]; then
        break
    fi
    printf "%s\n  \"%s\"" "${_sep}" "${_rng}" >> msazure.json
    _sep=","
done <<DONE
$(curl -sSL "${_FIRSTLONGPART}${_DATE}.xml" | grep IpRange)
DONE
printf "\n]" >> msazure.json
echo "[$(basename "$0")] Fetched Microsoft Azure Cloud IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < msazure.json)"

exit 0
