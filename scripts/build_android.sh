#!/bin/bash

source "$(dirname "$0")"/env.sh

if [[ -z "$ANDROID_ABI" ]]; then
  if [ $# -lt 1 ]; then
    echo "Please specific the arch(arm64, arm, x64, x86), for example:"
    echo "./build_android.sh arm64"
    exit 1
  fi
  ARCH=$1
else
  ARCH="${ANDROID_ABI}"
fi
OUTPUT="${WORKSPACE}/artifacts/android"

CC_VER="4.9"
EXTRA_OPTIONS=
TARGET_ARCH=$ARCH
case $ARCH in
arm)
  DEST_CPU="arm"
  TOOLCHAIN_NAME="armv7a-linux-androideabi"
  ;;
arm64)
  DEST_CPU="arm64"
  TOOLCHAIN_NAME="aarch64-linux-android"
  ;;
x86)
  DEST_CPU="ia32"
  TARGET_ARCH="ia32"
  TOOLCHAIN_NAME="i686-linux-android"
  EXTRA_OPTIONS="--openssl-no-asm"
  ;;
x64)
  DEST_CPU="x64"
  TOOLCHAIN_NAME="x86_64-linux-android"
  EXTRA_OPTIONS="--openssl-no-asm"
  ;;
*)
  echo "Unsupported architecture provided: $ARCH"
  exit 1
  ;;
esac

ANDROID_SDK_VERSION=24

PREFIX="$OUTPUT"/"${ARCH}"
mkdir -p "$PREFIX"

if [[ "$CI" != true ]]; then
  # Link different directories for different arch, this makes the local build faster
  BUILD_DIR="$PWD"/build/android/"$ARCH"
  LINK_DIR="$NODE_SOURCE_PATH"/out
  if [ -d "$LINK_DIR" ]; then
    unlink "$LINK_DIR"
  fi
  mkdir -p "$BUILD_DIR"
  ln -s "$BUILD_DIR" "$LINK_DIR"
fi

export CC_host=$(which gcc)
export CXX_host=$(which g++)

# HOST_OS=`uname -s | tr "[:upper:]" "[:lower:]"`

SUFFIX="$TOOLCHAIN_NAME$ANDROID_SDK_VERSION"

HOST_ARCH=$(uname -m)
HOST_OS=
WORKER_COUNT=
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$(uname -s|awk '{print tolower($0)}')-$HOST_ARCH
case $(uname -s) in
Linux)
  WORKER_COUNT=$(nproc --all)
  HOST_OS=linux
  host_gcc_version=$($CC_host --version | grep gcc | awk '{print $NF}')
  major=$(echo $host_gcc_version | awk -F . '{print $1}')
  minor=$(echo $host_gcc_version | awk -F . '{print $2}')
  if [ -z $major ] || [ -z $minor ] || [ $major -lt 6 ] || [ $major -eq 6 -a $minor -lt 3 ]; then
    echo "host gcc $host_gcc_version is too old, need gcc 6.3.0"
    exit 1
  fi
  ;;
Darwin)
  WORKER_COUNT=$(sysctl -n hw.ncpu)
  HOST_OS=mac
  ;;
esac

export PATH=$TOOLCHAIN/bin:$PATH
export CC=$TOOLCHAIN/bin/$SUFFIX-clang
export CXX=$TOOLCHAIN/bin/$SUFFIX-clang++

GYP_DEFINES="target_arch=$TARGET_ARCH"
GYP_DEFINES+=" v8_target_arch=$TARGET_ARCH"
GYP_DEFINES+=" v8_target_os=android"
GYP_DEFINES+=" android_target_arch=$TARGET_ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
export GYP_DEFINES

cd $NODE_SOURCE_PATH

./configure \
  --dest-cpu=$DEST_CPU \
  --dest-os=android \
  --cross-compiling \
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
  --without-corepack \
  --with-intl=none \
  --shared \
  ${EXTRA_OPTIONS} \
  # --debug-lib \
  # --debug-node \
  # --openssl-no-asm \
  # --v8-non-optimized-debug \
  # --v8-enable-object-print \
  # --verbose \
  # --without-intl \
  # --verbose \
  # --build-v8-with-gn \
  # --without-inspector \

make -j${WORKER_COUNT}
make install