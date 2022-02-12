#!/bin/bash
set -e

export WORKSPACE=$(realpath "$(dirname "$0")"/../)

if [[ -z "$NODE_SOURCE_PATH" ]]; then
    export NODE_SOURCE_PATH=$(realpath ./node)
fi