#!/bin/bash
source "$(dirname "$0")"/env.sh

stash_new_files() {
  # add zero-length blob to the index for new untracked files
  # shellcheck disable=SC2207
  git status --porcelain | grep -E "^\?\?" | sed s/^...// | xargs git add -N
}

generate_patches() {
  echo "Generating patch files..."
  cd "$NODE_SOURCE_PATH" || exit
  IFS=$'
  '

  stash_new_files

  # shellcheck disable=SC2207
  MODIFIED_FILES=($(git status --porcelain | grep -E "^ [AM]" | sed s/^...//))
  for value in "${MODIFIED_FILES[@]}"; do
    git diff "$value" >"../patches/${value//\//-}.patch"
  done

  unset IFS
  cd ../ || exit
}

apply_patches() {
  echo "Applying patch files..."
  cd "$NODE_SOURCE_PATH" || exit
  if [[ $(git status --porcelain) ]]; then
    if [[ $1 == "-f" ]]; then
      echo "Dropping local changes..."
      stash_new_files
      git reset HEAD --hard
    else
      echo >&2 "Error: local changes in node directory are not empty, you must drop them firstly"
      exit 1
    fi
  fi
  PATCHES=$(find ../patches -name \*.patch)
  for patch in $PATCHES; do
    echo "Applying patch: $(basename "$patch")"
    patch --silent -p1 <"$patch"
  done
  cd ../ || exit
}

reset_changes() {
  cd "$NODE_SOURCE_PATH" || exit
  git reset HEAD --hard
  cd ../ || exit
  apply_patches
}

if [ $# -lt 1 ]; then
  echo "usage: patch.sh <command> [options]"
  echo ""
  echo "available commands:"
  echo "  apply     apply the changes from patch files into node source, add -f to force apply"
  echo "  generate  generate patch files from the git diff"
  exit 1
fi
case $1 in
generate)
  generate_patches
  ;;

apply)
  apply_patches "$2"
  ;;

reset)
  reset_changes
  ;;
esac
