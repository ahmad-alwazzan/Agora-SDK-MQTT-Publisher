#!/bin/bash

set -e

SOURCE_DIR=../src

#copy the source files and module.json
echo "Copying the sources files"
cp -a --verbose ${SOURCE_DIR}/. ./target/arm32v7/docker/lib/ 
if [ $? -ne 0 ]
then
    echo "there was an error"
fi
cp --verbose ${SOURCE_DIR}/../module.json ./target/arm32v7/docker
if [ $? -ne 0 ]
then
    echo "there was an error"
fi

