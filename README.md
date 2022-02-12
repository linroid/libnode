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
 After build successfully, all the artifacts are under `outputs` directory