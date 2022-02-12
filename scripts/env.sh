#!/bin/bash
set -e

if [[ -z "$NODE_SOURCE_PATH" ]]; then
    export NODE_SOURCE_PATH=$(realpath ./node)
fi