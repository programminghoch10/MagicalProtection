#!/bin/bash
set -e
set -u
set -o pipefail
shopt -s inherit_errexit
IFS=$'\n'
cd "$(dirname "$(readlink -f "$0")")"

[ -f .gitauth ] && source .gitauth
[ -z "${GITHUB_TOKEN-}" ] && echo "missing GITHUB_TOKEN" && exit 1

for cmd in git curl jq; do
  [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

FILE="${1-}"
# shellcheck disable=SC2012
[ -z "$FILE" ] && FILE=$(ls MagicalProtection-*.zip | tail -n 1)
[ -z "$FILE" ] && echo "require input file" && exit 1

function getprop() {
  local prop="$1"
  local content
  content=$(cat)
  [ -z "$content" ] && echo "missing content in getProp" >&2 && return 1
  grep -q "^$prop" <<< "$content" || return 1
  grep "^$prop" <<< "$content" | head -n 1 | cut -d'=' -f2
}

FILE_MODULE_PROP=$(unzip -p "$FILE" module.prop)

./update.sh checkOutDeploy

DEPLOY_VERSION=$(getprop version < deploy/module.prop)
DEPLOY_VERSIONCODE=$(getprop versionCode < deploy/module.prop)
FILE_VERSION=$(getprop version <<< "$FILE_MODULE_PROP")
FILE_VERSIONCODE=$(getprop versionCode <<< "$FILE_MODULE_PROP")

echo "deploy version = $DEPLOY_VERSION" >&2
echo "  file version = $FILE_VERSION" >&2

[ "$FILE_VERSIONCODE" -le "$DEPLOY_VERSIONCODE" ] && {
  echo "versioncode did not increase, no deploy required."
  ./update.sh removeDeploy
  exit 0
}

NEW_TAG_NAME=$(getprop versionTag <<< "$FILE_MODULE_PROP")

export FILENAME="$FILE"
export VERSIONTAG="$NEW_TAG_NAME"
export VERSION="$FILE_VERSION"
VERSIONCODE=$(getprop versionCode <<< "$FILE_MODULE_PROP")
export VERSIONCODE
envsubst < update_template.json > deploy/update.json
echo "$FILE_MODULE_PROP" > deploy/module.prop

(
  cd deploy
  git add module.prop update.json
  git commit -m "$VERSIONTAG" || exit
  git push -q
) || exit 1

GITHUB_OWNER="programminghoch10"
GITHUB_REPO="MagicalProtection"

COMMITISH=$(getprop versionModuleCommitHash <<< "$FILE_MODULE_PROP")

CURL_GITHUB_API_ARGS=(
  --fail
  --location
  --show-error
  --header "Accept: application/vnd.github+json"
  --header "Authorization: Bearer $GITHUB_TOKEN"
  --header "X-GitHub-Api-Version: 2022-11-28"
)

CREATE_RELEASE_RESPONSE=$(curl \
  --silent \
  "${CURL_GITHUB_API_ARGS[@]}" \
  --request POST \
  "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases" \
  --data "{
      \"tag_name\":\"$VERSIONTAG\",
      \"target_commitish\":\"$COMMITISH\",
      \"name\":\"$VERSIONTAG\",
      \"body\":\"$(cat deploy/changelog.md)\",
      \"draft\":true
      }"
)

./update.sh removeDeploy

RELEASE_ID=$(jq --raw-output .id <<< "$CREATE_RELEASE_RESPONSE")
[ -z "$RELEASE_ID" ] && echo "failed to acquire created release id" && exit 1

curl \
  "${CURL_GITHUB_API_ARGS[@]}" \
  --request POST \
  --header "Content-Type: application/zip" \
  "https://uploads.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/$RELEASE_ID/assets?name=$(basename "$FILENAME")" \
  --data-binary "@$FILENAME" \
  --output /dev/null

curl \
  --silent \
  "${CURL_GITHUB_API_ARGS[@]}" \
  --request PATCH \
  "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/$RELEASE_ID" \
  --data '{"draft":false}' \
  --output /dev/null

./update.sh pushDeploy
