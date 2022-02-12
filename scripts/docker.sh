#!/usr/bin/env bash

set -e
set -x

if [ $# -lt 2 ]; then
  echo "$0 should have at least 2 parameters: arch, output_dir"
  exit 1
fi

ARCH=$1
OUTPUT=$2
mkdir -p "$OUTPUT"

NODE_SOURCE=$(realname ./node)
IMAGE_NAME=ndk20b

case $COMMAND in
build)
  docker -D build -t "$IMAGE_NAME" -f "Dockerfile" .
  ;;
clean)
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCE",target="$NODE_SOURCE" \
    --mount type=bind,source="$OUTPUT",target=/output \
    -w "${NODE_SOURCE}"/knode \
    $IMAGE_NAME ./build.sh clean "$ARCH" /output
  ;;
configure)
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCE",target="$NODE_SOURCE" \
    --mount type=bind,source="$OUTPUT",target=/output \
    -w "${NODE_SOURCE}"/knode \
    $IMAGE_NAME ./build.sh configure "$ARCH" /output
  ;;
make)
  echo building "$ARCH"
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCE",target="$NODE_SOURCE" \
    --mount type=bind,source="$OUTPUT",target=/output \
    -w "${NODE_SOURCE}"/knode \
    $IMAGE_NAME ./build.sh make "$ARCH" /output
  ;;
*)
  echo "Unsupported command provided: $COMMAND"
  exit 1
  ;;
esac
