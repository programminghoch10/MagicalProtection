#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n'
cd "$(dirname "$(readlink -f "$0")")"

for cmd in git curl; do
  [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

function checkOutBranch() {
  local branch="$1"
  local folder="${2-}"
  [ -z "$folder" ] && folder="$branch"
  ! git branch | grep -q "$branch" && git fetch origin "$branch":"$branch"
  [ -d "$folder" ] && rm -rf "$folder"
  mkdir "$folder"
  git clone -q $(pwd) "$folder"
  cd "$folder"
  git config --local push.autoSetupRemote true
  git fetch -q origin "$branch":"$branch"
  git checkout -q "$branch"
  cd ..
}

function removeBranch() {
  local branch="$1"
  local folder="${2-}"
  [ -z "$folder" ] && folder="$branch"
  rm -rf "$folder"
}

function pushBranch() {
  local branch="$1"
  git push origin "$branch"
}

case "${1-}" in
  checkOutHosts)
    checkOutBranch hosts
    exit
    ;;
  removeHosts)
    removeBranch hosts
    exit
    ;;
  pushHosts)
    pushBranch hosts
    exit
    ;;
  checkOutDeploy)
    checkOutBranch deploy
    exit
    ;;
  removeDeploy)
    removeBranch deploy
    exit
    ;;
  pushDeploy)
    pushBranch deploy
    exit
    ;;
esac

$0 checkOutHosts

while read -r line; do
  grep -q '^\s*#' <<< "$line" && continue
  file=$(cut -d',' -f1 <<< "$line")
  url=$(cut -d',' -f2 <<< "$line")
  curl \
    -o hosts/"$file" \
    --etag-save hosts/"$file".etag \
    --etag-compare hosts/"$file".etag \
    "$url"
done < lists.txt

(
  cd hosts
  for file in *; do
    listsfile=$(sed -e 's/\.etag$//' <<< "$file")
    grep -q "^$listsfile" < ../lists.txt && continue
    rm "$file"
  done
)

(
  cd hosts
  git add .
  git commit -m "Update lists" || true
  git push -q
)

$0 removeHosts

$0 pushHosts
