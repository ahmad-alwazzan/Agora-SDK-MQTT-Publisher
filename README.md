# Welcome to Agora Edge SDK

###### Build and debug your module
Module directory structure:
    .
    ├── build       *contains build scripts*
    ├── inc         *include files (C++ only)*
    ├── deps        *all module external dependencies should go here*
    ├── module.json *module configuration*
    └── src         *source files*

Build your module code:

Build your code using VSCode build task:
```
CTL+SHIFT+P and Enter
>Tasks: Run Task
Run the build task
```

Build your module code from the command line:
```
cd build
./build-x86_64.sh
```

Build your module code from the command line and run unit test:
```
cd build
./build-x86_64.sh -u
```

Build your module container image:
```
cd build/target/x86_64/docker
./build-module.sh -r {registry URL} -t {image tag name}
```
