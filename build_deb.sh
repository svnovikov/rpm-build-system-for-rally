#!/bin/bash
set -x
# NOTE: run this script as root!

WORK_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_CONTAINER="ubuntu/deb_builder"
TARGET_CONTAINER="rallyd-isolated"

cd ${WORK_DIR}

# Build docker image with rally, rallyd and haproxy
docker build -t ${TARGET_CONTAINER} ${WORK_DIR}/mos_isolated
docker save -o ${WORK_DIR}/rallyd.tar ${TARGET_CONTAINER}

# Build docker image
cp Dockerfile.deb Dockerfile
docker build -t ${BUILD_CONTAINER} .
docker run -t ${BUILD_CONTAINER} /bin/sh -c "exit"

# Get container & images ids
image_id=$(docker images -a | grep ${BUILD_CONTAINER} | awk '{print $3}')
container_id=$(docker ps -a | grep ${BUILD_CONTAINER} | awk '{print $1}')
rallyd_image_id=$(docker images -a | grep ${TARGET_CONTAINER} | awk '{print $3}')

# Download created rpm
docker cp ${container_id}:/build/rallyd-docker_1.0.0_all.deb .

# Clean up
docker rm ${container_id}
docker rmi -f ${image_id}
docker rmi -f ${rallyd_image_id}
rm rallyd.tar
