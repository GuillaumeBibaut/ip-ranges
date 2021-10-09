#!/bin/sh

if [ $# -ne 2 ]; then
    echo "$(basename "$0") TOKEN PROJECT"
    exit 1
fi

_TOKEN="$1"
_PROJECT="$2"

echo "$(date)"
echo "Waiting for ranges..."

_pids=""
./scripts/gcp-ranges.sh &
_pids="$! ${_pids} "
./scripts/aws-ranges.sh &
_pids="$! ${_pids} "
./scripts/msa-ranges.sh &
_pids="$! ${_pids} "
./scripts/shd-ranges.sh &
_pids="$! ${_pids} "
./scripts/she-ranges.sh &
_pids="$! ${_pids} "
wait ${_pids}

echo "Checking for diffs..."
for _rng in amazonaws googlecloud msazure spamhausdrop spamhausedrop; do
    if [ ! -s "${_rng}.json" ]; then
        echo "${_rng}.json is empty, check this error please!"
        exit 3
    fi
    if git diff --exit-code "${_rng}.json"; then
        echo "${_rng} no changes"
    else
        _data="$(printf "{\"branch\": \"master\", \"author_email\": \"yom@iaelu.net\", \"author_name\": \"Guillaume Bibaut\", \"encoding\": \"base64\", \"commit_message\": \"%s changes\"}" "${_rng}")"
        _base64="$(base64 -w0 "${_rng}.json")"
        _url="$(printf "https://gitlab.com/api/v4/projects/%s/repository/files/%s%%2Ejson" "${_PROJECT}" "${_rng}")"

        curl -sS --request PUT \
            --header "PRIVATE-TOKEN: ${_TOKEN}" \
            --header "Content-Type: application/json" \
            --data "${_data}" \
            --data-urlencode "${_base64}" \
            "${_url}"
        _ret=$?
        if [ ${_ret} -ne 0 ]; then
            echo "${_rng} curl command failed"
            exit 2
        fi
        echo
    fi
done

exit 0
