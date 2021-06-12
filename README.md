# Agora-SDK-MQTT-Publisher
This module is developed by 'KNPC TEAM A'. to build the module with Agora Edge SDK follow the instructions below.

###### Build and debug your module
Module directory structure:
    .
    ├── build       *contains build scripts*
    ├── inc         *include files (C++ only)*
    ├── deps        *all module external dependencies should go here*
    ├── module.json *module configuration*
    └── src         *source files*

Build your module code:

Build your module container image:
```
cd build/target/x86_64/docker
./build-module.sh -r {registry URL} -t {image tag name}
```
