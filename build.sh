#!/bin/bash
mkdir -p ./artifacts/android
./scripts/patch.sh apply -f
./scripts/build_android.sh arm64 ./artifacts/android
./scripts/build_android.sh arm ./artifacts/android
