#!/bin/bash

set -e

SCRIPT=`readlink -f $0`
SCRIPTPATH=`dirname "$SCRIPT"`
cd ${SCRIPTPATH}

TAG_ARRAY=`whoami`
REBUILD=0
PUBLISH=0
MODULENAME="mqtt-publisher"
PLATFORM="x86_64"
REGISTRYURL="localhost:5000"
IONPROJECTPREFIX=""

HBM_BASE_PATH=../../../../deps/hermes-base-cpp
HBM_RELEASE_FILE=${HBM_BASE_PATH}/hbm-release.json
HBM_RELEASE_SUPPORT_LIB=${HBM_BASE_PATH}/build/target/manage-release-info.sh

source $HBM_RELEASE_SUPPORT_LIB

HBM_BASE_OPTION=" --build-arg hbmBaseImage=$(get_base_image $HBM_RELEASE_FILE $PLATFORM)"


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
            HBM_BASE_OPTION=" --build-arg hbmBaseImage="$OPTARG
            ;;


     esac
done

echo "$(tput setaf 2)Building module ${MODULENAME} ${PLATFORM}$(tput sgr0)"

pushd ../../../

rm -rf  tests/*
./build-x86_64.sh -u

BUILD_RC=$?
   
if test $BUILD_RC -ne 0; then
   echo "$(tput setaf 1)ERROR: Building binaries for module ${MODULENAME} ${PLATFORM} failed$(tput sgr0)"
   exit $BUILD_RC
fi
   

#TEST_RESULTS=../platform/artifacts/unit-tests/${MODULENAME}
#rm -rf $TEST_RESULTS
#mkdir -p $TEST_RESULTS

#rsync -rL --safe-links --ignore-missing-args tests/* $TEST_RESULTS



#Gather information to create module section in Hermes deployment file
#
# - module.json         : module defintions, and routes
# - image_spec.json     : docker images being pushed
# - deployment.json     : module create options ( volume mount, port biding, etc)
#

DEPLOYMENT_LOCATION=../platform/artifacts/docker/${PLATFORM}/${MODULENAME}
rm -rf $DEPLOYMENT_LOCATION || true
mkdir -p $DEPLOYMENT_LOCATION

cp target/x86_64/docker/deployment.json $DEPLOYMENT_LOCATION
cp ../module.json $DEPLOYMENT_LOCATION

tagArrayJson=`for tag in ${TAG_ARRAY[@]}; do printf "\"$tag\", ";done`
tagArrayJson=${tagArrayJson::-2}
imageName=${REGISTRYURL}/${PLATFORM}/${MODULENAME}
cat << JSON_END > ${DEPLOYMENT_LOCATION}/image-spec.json
{
  $HBM_BASE_JSON
  "ImageName":  "$imageName",
  "Target":  "$PLATFORM",
  "Tags": [
    $tagArrayJson
  ]
}
JSON_END

/usr/local/tools/ci-tools/create-module-deployment.sh -d ${DEPLOYMENT_LOCATION} | jq . > ${DEPLOYMENT_LOCATION}/module-deployment-${MODULENAME}.json || true


popd

echo "$(tput setaf 2)Building image: ${REGISTRYURL}/${PLATFORM}/${MODULENAME}:${TAG_ARRAY[@]}$(tput sgr0)"


REFERENCE_IMAGE_NAME="${REGISTRYURL}/${PLATFORM}/${MODULENAME}":`date +%Y%m%d_%H%M%S`

docker build --rm $HBM_BASE_OPTION -t $REFERENCE_IMAGE_NAME .
for TAG in "${TAG_ARRAY[@]}"
do
	docker tag $REFERENCE_IMAGE_NAME  ${REGISTRYURL}/${PLATFORM}/${MODULENAME}:${TAG}
done


BUILD_RC=$?
   
if test $BUILD_RC -ne 0; then
    echo "$(tput setaf 1)ERROR: Building image for module ${MODULENAME} ${PLATFORM} failed$(tput sgr0)"
    exit $BUILD_RC
fi

if test $PUBLISH -ne 0; then
    echo "$(tput setaf 2)Pushing image: ${REGISTRYURL}/${PLATFORM}/${MODULENAME}:${TAG_ARRAY[@]}$(tput sgr0)"

	for TAG in "${TAG_ARRAY[@]}"
	do
		docker push ${REGISTRYURL}/${PLATFORM}/${MODULENAME}:${TAG}
	done
    
    BUILD_RC=$?

    if test $BUILD_RC -ne 0; then
       echo "$(tput setaf 1)ERROR: Pushing image for module ${MODULENAME} ${PLATFORM} failed$(tput sgr0)"
       exit $BUILD_RC
    fi
fi

exit 0

