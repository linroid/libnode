# node_builder

Build Node.js shared library for knode

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
 Build scripts in this repository use patch files(under `patches` directory) to apply the changes for Node.js, this can make the Node.js upgrade work be easier and makes it intuitive to know what changes we made in our purpose.
 If you did some changes in node's codebase, you should generate patches files and commit `*.patch` files instead of commits changes directly.

 Before doing your change, update local changes to latest, this will drop your local changes under `node` directory:
 ```
 git pull origin main
 ./scripts/patch.sh apply -f
 ```
 Now you can edit any files in Node.js under the `node` directory, to commit your changes, you need to update the patch files:
 ```
 ./scripts/patch.sh generate
 ```
 Then commit these changes in patch files
 