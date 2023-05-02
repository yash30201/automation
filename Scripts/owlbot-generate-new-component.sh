#!/bin/bash

printf "To run this script for generating a new component, you need to clone \
two repositories locally:-\n * https://github.com/googleapis/google-cloud-php\n \
* https://github.com/googleapis/googleapis\n\n"
printf "IMPORTANT:- Run this script from google-cloud-php directory ***\n\n"

GOOGLE_CLOUD_PHP=$(pwd)
GOOGLEAPIS=""
COMPONENT_NAME_WITH_RELATIVE_PATH=""
COMPONENT_NAME=""
BASE_PROTO_RELATIVE_PATH_TO_ADD_COMPONENT=""
if [ "$#" -eq 4 ]
then
    GOOGLEAPIS="$1"
    COMPONENT_NAME="$2"
    COMPONENT_NAME_WITH_RELATIVE_PATH="$3"
    BASE_PROTO_RELATIVE_PATH_TO_ADD_COMPONENT="$4"
else
    printf "usage:\nowlbot-generate.sh \ \n"
    printf "[GOOGLEAPIS_PATH] \ \n"
    printf "[COMPONENT_NAME] \ \n"
    printf "[COMPONENT_NAME_WITH_RELATIVE_PATH] \ \n"
    printf "[BASE_PROTO_RELATIVE_PATH_TO_ADD_COMPONENT]\n\n"
    printf "For eg:-\n"
    printf "[COMPONENT_NAME] => StorageInsights\n"
    printf "[COMPONENT_NAME_WITH_RELATIVE_PATH] => google/cloud/storageinsights\n"
    printf "[COMPONENT_NAME_WITH_RELATIVE_PATH] => google/cloud/storageinsights/v1/storageinsights.proto\n\n"
    printf "Note: If there are multiple base proto files then you can place "
    printf "of any service proto file here.\n"
    exit 1;
fi

cd dev
composer update
cd ..
dev/google-cloud add-component $BASE_PROTO_RELATIVE_PATH_TO_ADD_COMPONENT


# Helper methods

# capture the output of a command so it can be retrieved with ret
cap () { tee /tmp/capture.out; }
# return the output of the most recent command that was captured by cap
ret () { cat /tmp/capture.out; }

# Going into google apis to generate php files from protos using bazel
cd $GOOGLEAPIS

# Finding the components to build
bazel query \
"filter(\"-(php)$\", kind(\"rule\", //$COMPONENT_NAME_WITH_RELATIVE_PATH/...:*))" | \
grep -v -E ":(proto|grpc|gapic)-.*-php$" | cap

COMPONENTS_TO_BUILD=$(ret)

# building the bazel files
bazel build $COMPONENTS_TO_BUILD


# Copy code step to copy files from bazel-bin to your repo's folder
# This will generate code into owl-bot-staging folder.
docker run --rm --user $(id -u):$(id -g) -v $GOOGLE_CLOUD_PHP:/repo \
-v $GOOGLEAPIS/bazel-bin:/bazel-bin \
gcr.io/cloud-devrel-public-resources/owlbot-cli:latest \
copy-bazel-bin \
--config-file=$COMPONENT_NAME/.OwlBot.yaml \
--source-dir /bazel-bin \
--dest /repo

# Process and put files inside the Component from owl-bot-staging folder
docker run --user $(id -u):$(id -g) --rm \
-v $GOOGLE_CLOUD_PHP:/repo \
-w /repo gcr.io/cloud-devrel-public-resources/owlbot-php

# Delete the bazel-bin generated files for this component as they are unnecessary
# now.
rm -rf $GOOGLEAPIS/bazel-bin/$COMPONENT_NAME_WITH_RELATIVE_PATH
