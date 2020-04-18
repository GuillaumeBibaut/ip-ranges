#!/bin/sh

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
    if ! git diff --quiet "${_rng}.json"; then
        git diff --exit-code "${_rng}.json"
        printf "%s changes, cleaning local changes..." "${_rng}"
        git restore "${_rng}.json"
        printf " done!\n"
    fi
done

exit 0
