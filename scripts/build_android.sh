#!/bin/bash

# In order to cross-compile node for Android using NDK, run:
#   source android-configure <path_to_ndk> [arch]
#
# By running android-configure with source, will allow environment variables to
# be persistent in current session. This is useful for installing native node
# modules with npm. Also, don't forget to set the arch in npm config using
# 'npm config set arch=<arch>'

set -e
set -x

if [ $# -lt 2 ]; then
  echo "$0 should have at least 2 parameters: target_arch, output_dir, for example"
  echo "./build.sh arm64 $PWD/artifacts/"
  exit 1
fi

ARCH=$1
OUTPUT=$(realpath "$2")

CC_VER="4.9"

case $ARCH in
arm)
  DEST_CPU="arm"
  TOOLCHAIN_NAME="armv7a-linux-androideabi"
  ABI="armeabi-v7a"
  ;;
arm64 | aarch64)
  DEST_CPU="arm64"
  TOOLCHAIN_NAME="aarch64-linux-android"
  ABI="arm64-v8a"
  ;;
x86)
  DEST_CPU="ia32"
  TOOLCHAIN_NAME="i686-linux-android"
  ABI="x86"
  ;;
x86_64)
  DEST_CPU="x64"
  TOOLCHAIN_NAME="x86_64-linux-android"
  ARCH="x64"
  ABI="x86_64"
  ;;
*)
  echo "Unsupported architecture provided: $ARCH"
  exit 1
  ;;
esac

ANDROID_SDK_VERSION=23

NODE_SOURCE=$PWD/node
PREFIX="$OUTPUT"/"${ABI}"
mkdir -p "$PREFIX"

BUILD_DIR="$PWD"/build/android/"$ARCH"
LINK_DIR="$NODE_SOURCE"/out
if [ -d "$LINK_DIR" ]; then
  unlink "$LINK_DIR"
fi
mkdir -p "$BUILD_DIR"
ln -s "$BUILD_DIR" "$LINK_DIR"

export CC_host=$(which gcc)
export CXX_host=$(which g++)

# HOST_OS=`uname -s | tr "[:upper:]" "[:lower:]"`

SUFFIX="$TOOLCHAIN_NAME$ANDROID_SDK_VERSION"

HOST_ARCH=$(uname -m)
HOST_OS=
WORKER_COUNT=
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-$HOST_ARCH
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

GYP_DEFINES="target_arch=$ARCH"
GYP_DEFINES+=" v8_target_arch=$ARCH"
GYP_DEFINES+=" v8_target_os=android"
GYP_DEFINES+=" android_target_arch=$ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
export GYP_DEFINES

cd $NODE_SOURCE

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
  --with-intl=none \
  --shared \
  --release-urlbase=https://github.com/dorajs/node/
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