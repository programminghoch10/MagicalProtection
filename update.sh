#!/bin/bash
set -e -u
IFS=$'\n'

function checkOutHosts() {
  ! git branch | grep -q hosts && git fetch origin hosts:hosts
  [ -d hosts ] && rm -rf hosts
  mkdir hosts
  git clone $(pwd) hosts
  cd hosts
  git fetch origin hosts:hosts
  git checkout hosts
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
  git push
)

$0 removeHosts
