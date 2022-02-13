#!/bin/bash
set -e
printenv

export WORKSPACE=$(realpath "$(dirname "$0")"/../)

if [[ -z "$NODE_SOURCE_PATH" ]]; then
    export NODE_SOURCE_PATH=$(realpath ./node)
fi

WORKER_COUNT=2
case $(uname -s) in
Linux)
  WORKER_COUNT=$(nproc --all)
  ;;
Darwin)
  WORKER_COUNT=$(sysctl -n hw.ncpu)
  ;;
esac
