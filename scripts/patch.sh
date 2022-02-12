#!/bin/bash
set -e
generate_patches() {
  echo "Generating patch files..."
  cd ./node || exit
  IFS=$'
  '

  # add zero-length blob to the index for new untracked files
  # shellcheck disable=SC2207
  git status --porcelain | grep -E "^\?\?" | sed s/^...// | xargs git add -N

  # shellcheck disable=SC2207
  MODIFIED_FILES=($(git status --porcelain | grep -E "^ [AM]" | sed s/^...//))
  for value in "${MODIFIED_FILES[@]}"; do
    git diff "$value" > "../patches/${value//\//-}.patch"
  done

  unset IFS
  cd ../ || exit
}

apply_patches() {
  echo "Applying patch files..."
  cd ./node || exit
  if [[ $(git status --porcelain) ]]; then
    >&2 echo "Error: local changes in node directory are not empty, you must drop them firstly"
  else
    PATCHES=$(find ../patches -name \*.patch)
    for patch in $PATCHES; do
      echo "Applying patch: $(basename "$patch")"
      patch --silent -p1 < "$patch"
  	done
  fi
}

if [ $# -lt 1 ]; then
  echo "usage: patch.sh <command>"
  echo ""
  echo "available commands:"
  echo "  apply     apply the changes from patch files into node source"
  echo "  generate  generate patch files from the git diff"
  exit 1
fi
case $1 in
generate)
  generate_patches
  ;;

apply)
  apply_patches
  ;;
esac
