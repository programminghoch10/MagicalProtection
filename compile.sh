#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n'
renice -n 19 $$ &>/dev/null
cd "$(dirname "$(readlink -f "$0")")"

for cmd in git zip base64; do
  [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

git clean -fdxq magiskmodule/
rm -f MagicalProtection-*.zip

./update.sh checkOutHosts

function getCommitCount() {
  local folder="${1-.}"
  (
    cd "$folder"
    git rev-list --count HEAD
  )
}

git diff --exit-code --quiet && LOCALCHANGES=false || LOCALCHANGES=true
$LOCALCHANGES && CHANGES="+" || CHANGES="-"
MODULE_COMMITS=$(getCommitCount)
HOSTS_COMMITS=$(getCommitCount hosts)
VERSIONCODE=$MODULE_COMMITS$(printf '%05d' $HOSTS_COMMITS)
COMMITHASH=$(git log -1 --pretty=%h)
COMMITHASHFULL=$(git log -1 --pretty=%H)
VERSIONTAG=mv$MODULE_COMMITS-hv$HOSTS_COMMITS
VERSION=$VERSIONTAG$CHANGES$COMMITHASH
FILENAME=MagicalProtection-$VERSIONTAG
LOCALDIFF=$(git diff --no-color --irreversible-delete | base64 -w 0)

declare -x VERSION VERSIONCODE VERSIONTAG MODULE_COMMITS HOSTS_COMMITS COMMITHASHFULL LOCALCHANGES LOCALDIFF
envsubst < module.prop > magiskmodule/module.prop

cp -f README.md magiskmodule/README.md

mkdir -p magiskmodule/system/etc
cat hosts/* \
| grep -v '^\s*#' \
| sed -e '/^$/d' \
| sort \
| uniq \
> magiskmodule/system/etc/hosts

./update.sh removeHosts

(
  cd magiskmodule
  zip -r -9 -q ../"$FILENAME" .
)
