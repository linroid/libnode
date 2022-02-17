# libnode

[![Build Release](https://github.com/linroid/node_builder/actions/workflows/build_release.yml/badge.svg)](https://github.com/linroid/node_builder/actions/workflows/build_release.yml) [![v16.14.0](https://img.shields.io/badge/Node.js-v16.14.0-blue)](https://github.com/nodejs/node/blob/master/doc/changelogs/CHANGELOG_V16.md#v16.14.0)

Build Node.js shared library for multiple platforms

## Build from source
 - Prepare build environment

   __macOS__:
   ```bash
   brew install coreutils
   ```
   __Ubuntu__:
   ```bash
   apt-get install python g++ gcc make gcc-multilib g++-multilib lib32z1 -y
   ```

 - Download the Node.js source code
    ```bash
    git clone https://github.com/nodejs/node.git
    cd node
    git checkout v16.7.0
    ```
 - Apply patches for knode
    ```bash
   ./scripts/patch.sh apply
    ```
 - Start building, get some ☕️:
    ```bash
   ./build.sh
    ```
 After build successfully, all the artifacts are under `artifacts` directory

## Upgrade Node.js

 ```
 cd node
 ```

 - Stash changes:
   ```
   git stash
   ```
 - Switch to newer Node.js
   ```
   git fetch origin
   git checkout vxx.xx.x
   ```
 - Apply the changes and resolve conflicts
   ```
   git stash pop
   ```

## Modify Node.js
 Build scripts in this repository use [patch](https://man7.org/linux/man-pages/man1/patch.1.html) files(under the `patches` directory) to apply changes for Node.js, so the Node.js upgrade work can be easier and it is intuitive to know what changes we've made.
 
 If you need to do some changes in node's codebase, you should generate patches files and commit `*.patch` files instead of commiting changes directly.

 Before doing your change, make sure your local changes is up-to-date:
 ```
 git pull origin main
 # your local changes under `node` directory will be dropped
 ./scripts/patch.sh apply -f
 ```
 Now you can edit any files in Node.js under the `node` directory, to commit your changes, you need to update the patch files:
 ```
 ./scripts/patch.sh generate
 ```

 
