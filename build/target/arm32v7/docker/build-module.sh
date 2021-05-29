#!/bin/bash

set -e

SCRIPT=`readlink -f $0`
SCRIPTPATH=`dirname "$SCRIPT"`
cd ${SCRIPTPATH}


TAG_ARRAY=`whoami`
REBUILD=0
PUBLISH=0
MODULENAME="mqtt-publisher
PLATFORM="arm32v7"
REGISTRYURL="localhost:5000"
IONPROJECTPREFIX=""
REMOTEIP="192.168.4.127"
HBM_BASE_IMAGE=""

REPO_BASE_DIR="../../../../"
CI_TOOLS_DIR="/usr/local/tools/ci-tools/"

HBM_BASE_PATH=../../../../deps/hermes-base-cpp
HBM_RELEASE_FILE=${HBM_BASE_PATH}/hbm-release.json
HBM_RELEASE_SUPPORT_LIB=${HBM_BASE_PATH}/build/target/manage-release-info.sh

source $HBM_RELEASE_SUPPORT_LIB

HBM_BASE_IMAGE=$(get_base_image $HBM_RELEASE_FILE $PLATFORM)


while getopts “t:cr:pb:” OPTION
do
     case $OPTION in
		 t)
			 TAGLIST=$OPTARG
			 IFS=', ' read -r -a TAG_ARRAY <<< "$TAGLIST"
			 ;;
		 c)
			 REBUILD=1
			 ;;
                 r)
                         REGISTRYURL=$OPTARG
			 ;;
                 p)      
                         PUBLISH=1
                         ;;

                 b)
                        HBM_BASE_IMAGE=$OPTARG
                        ;;

     esac
done

echo "$(tput setaf 2)Building module ${MODULENAME} ${PLATFORM}$(tput sgr0)"

pushd ../../../

./build-arm32v7.sh

BUILD_RC=$?
   
if test $BUILD_RC -ne 0; then
   echo "$(tput setaf 1)ERROR: Building binaries for module ${MODULENAME} ${PLATFORM} failed$(tput sgr0)"
   exit $BUILD_RC
fi
   
popd


echo "$(tput setaf 2)Building image: ${REGISTRYURL}/${PLATFORM}/${MODULENAME}:${TAG}$(tput sgr0)"

source ${CI_TOOLS_DIR}/build-armhf-module-container.sh
