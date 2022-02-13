#!/bin/bash

source "$(dirname "$0")"/env.sh

if [[ "$CI" = true ]]; then
  source "${WORKSPACE}"/scripts/patch.sh apply -f
fi

PREFIX="${WORKSPACE}/artifacts/macOS"
mkdir -p "$PREFIX"

cd $NODE_SOURCE_PATH

./configure \
  --prefix=$PREFIX \
  --v8-with-dchecks \
  --verbose \
  -C \
  --without-node-snapshot \
  --without-node-code-cache \
  --without-npm \
  --without-etw \
  --without-report \
  --without-dtrace \
  --with-intl=none \
  --shared \
  --release-urlbase=https://dorajs.com/

make -j${WORKER_COUNT}
make install