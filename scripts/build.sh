#!/bin/bash

source "$(dirname "$0")"/env.sh

PREFIX="${WORKSPACE}/artifacts/host"
mkdir -p "$PREFIX"

cd $NODE_SOURCE_PATH

./configure \
  --prefix=$PREFIX \
  --v8-with-dchecks \
  --verbose \
  -C \
  --without-npm \
  --without-etw \
  --without-report \
  --without-dtrace \
  --without-corepack \
  --with-intl=small-icu \
  --shared

make -j${WORKER_COUNT}
make install