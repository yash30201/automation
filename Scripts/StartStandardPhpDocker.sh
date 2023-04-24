#!/bin/bash

echo 'Usage: ./StartStandardPhpDocker.sh <[Optional]DOCKER_IMAGE_NAME> \
    <[Optional]DOCKER_CONTAINER_NAME>'

dockerImage=${DOCKER_IMAGE_NAME}
if [ -z "$1" ]
    then
        echo "Docker image not specified, using ${DOCKER_IMAGE_NAME}"
    else
        dockerImage=$1
fi

dockerContainer=${DOCKER_CONTAINER_NAME}
if [ -z "$2" ]
    then
        echo "Docker container not specified, using ${DOCKER_CONTAINER_NAME}"
    else
        dockerContainer=$2
fi

sudo docker run \
-ti --rm --privileged \
--volume $DOCKER_DIRECTORY_PATH_TO_MOUNT:/var/www/http/$DOCKER_MOUNT_FOLDER_NAME \
--workdir=/var/www/http/$DOCKER_MOUNT_FOLDER_NAME \
--env-file $DOCKER_ENV_FILE_PATH \
--volume $DOCKER_SERVICE_ACCOUNTS_PATH:/var/www/http/service-accounts \
--add-host=host.docker.internal:host-gateway \
--name $DOCKER_CONTAINER_NAME \
$DOCKER_IMAGE_NAME \
bash
