#!/bin/sh

if [ $# -ne 2 ]; then
    echo "$(basename "$0") TOKEN PROJECT"
    exit 1
fi

_TOKEN="$1"
_PROJECT="$2"

_pids=""
./scripts/gcp-ranges.sh &
_pids="${_pids} $!"
./scripts/aws-ranges.sh &
_pids="${_pids} $!"
./scripts/msa-ranges.sh &
_pids="${_pids} $!"
./scripts/shd-ranges.sh &
_pids="${_pids} $!"
./scripts/she-ranges.sh &
_pids="${_pids} $!"
wait ${_pids}

while read -r _rng; do
    if ! git diff --quiet "${_rng}.json"; then
        _data="$(printf "{\"branch\": \"master\", \"author_email\": \"yom@iaelu.net\", \"author_name\": \"Guillaume Bibaut\", \"content\": \"%s\", \"commit_message\": \"%s changes\"}" "$(tr '\n' '@' < "${_rng}.json" | sed -e s/@/\\\\n/g -e s/\"/\\\\\"/g)" "${_rng}")"
        _url="$(printf "https://gitlab.com/api/v4/projects/%s/repository/files/%s%%2Ejson" "${_PROJECT}" "${_rng}")"

        curl --request PUT \
            --header "PRIVATE-TOKEN: ${_TOKEN}" \
            --header "Content-Type: application/json" \
            --data "${_data}" \
            "${_url}"
        _ret=$?
        if [ ${_ret} -ne 0 ]; then
            echo "${_rng} curl command failed"
            exit 2
        fi
    fi
done <<EOD
amazonaws
googlecloud
msazure
spamhausdrop
spamhausedrop
EOD

