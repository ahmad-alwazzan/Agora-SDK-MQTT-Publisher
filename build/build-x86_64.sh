#!/bin/bash

set -e

TEST_STR=""
UNITTEST=0
MODULE_NAME=$(jq .Name ../module.json |tr -d '"')
SOURCE_DIR=../src

while getopts “uch” OPTION
do
     case $OPTION in
		u)
			TEST_STR="-Dtest=ON"
            UNITTEST=1
            ;;

     esac
done

#copy the source files and module.json
echo "Copying the sources files"
cp -a --verbose ${SOURCE_DIR}/. ./target/x86_64/docker/lib/ 
if [ $? -ne 0 ]
then
    echo "there was an error"
fi
cp --verbose ${SOURCE_DIR}/../module.json ./target/x86_64/docker
if [ $? -ne 0 ]
then
    echo "there was an error"
fi
