#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n'
cd "$(dirname "$(readlink -f "$0")")"

for cmd in git curl; do
  [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

function checkOutHosts() {
  ! git branch | grep -q hosts && git fetch origin hosts:hosts
  [ -d hosts ] && rm -rf hosts
  mkdir hosts
  git clone -q $(pwd) hosts
  cd hosts
  git fetch -q origin hosts:hosts
  git checkout -q hosts
  cd ..
}

function removeHosts() {
  rm -rf hosts
}

case "${1-}" in
  checkOutHosts)
    checkOutHosts
    exit
    ;;
  removeHosts)
    removeHosts
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
  git commit -m "Update lists"
  git push -q
)

$0 removeHosts

git push origin hosts
