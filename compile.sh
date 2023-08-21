#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n'
renice -n 19 $$ &>/dev/null
cd "$(dirname "$(readlink -f "$0")")"

[ -n "$(git status --porcelain)" ] && CHANGES="+" || CHANGES="-"
VERSIONCODE=$(git rev-list --count HEAD)
COMMITHASH=$(git log -1 --pretty=%h)
VERSION=v$VERSIONCODE$CHANGES\($COMMITHASH\)
FILENAME=MagicalProtection-$VERSION

declare -x VERSION VERSIONCODE
envsubst < module.prop > magiskmodule/module.prop

cp -f README.md magiskmodule/README.md

./update.sh checkOutHosts

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
