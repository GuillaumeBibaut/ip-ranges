#!/bin/sh

GITCMD="/usr/bin/git"
_TEMPDIR="/builds/${CI_PROJECT_PATH}/clone"

trap 'rm -rf "${_TEMPDIR}"; exit 1' 2

mkdir -p "${_TEMPDIR}"
${GITCMD} clone "https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git" "${_TEMPDIR}"
${GITCMD} config --global user.email "${GIT_USER_EMAIL:-$GITLAB_USER_EMAIL}"
${GITCMD} config --global user.name "${GIT_USER_NAME:-$GITLAB_USER_NAME}"

cd "${_TEMPDIR}"

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
        rm -rf "${_TEMPDIR}"
        exit 3
    fi
    if git diff --exit-code "${_rng}.json"; then
        echo "${_rng} no changes"
    else
        git add "${_rng}.json"
        git commit -m "${_rng} changes"
        git push origin "${CI_DEFAULT_BRANCH}"
        _ret=$?
        if [ ${_ret} -ne 0 ]; then
            echo "${_rng} git push command failed"
            rm -rf "${_TEMPDIR}"
            exit 2
        fi
        echo
    fi
done

rm -rf "${_TEMPDIR}"
exit 0
