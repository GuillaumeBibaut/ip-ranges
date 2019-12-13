#!/bin/sh

LOOKUP="nslookup"

_netblocks="_cloud-netblocks.googleusercontent.com"
_sep=""

recursenb() {
    local _nb _subnb _list

    _nb=$1
    if [ -z "${_nb}" ]; then
        return 0
    fi

    _list=$(${LOOKUP} -q=TXT ${_nb} 8.8.8.8 | grep spf1 | sed -E -e 's:^.*text...::' -e 's:"::g')
    for _item in ${_list}; do
        case "${_item}" in
        include*)
            _include=$(printf "%s" "${_item}" | sed -E 's:include\:::')
            recursenb "${_include}"
            ;;
        ip4*)
            _ip4=$(printf "%s" "${_item}" | sed -E 's:ip4\:::')
            printf "%s\n  \"%s\"" "${_sep}" "${_ip4}" >> googlecloud.json
            _sep=","
            ;;
        esac
    done
}

echo "[$(basename "$0")] Fetching Google Cloud Plateform IPv4 ranges..."
printf "[" > googlecloud.json
recursenb "${_netblocks}"
printf "\n]" >> googlecloud.json
echo "[$(basename "$0")] Fetched Google Cloud Plateform IPv4 ranges."
echo "[$(basename "$0")] Lines count: $(wc -l < googlecloud.json)"

exit 0
