#!/bin/bash
set -x
# NOTE: run this script as root!

WORK_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_CONTAINER="centos/rpm_builder"
TARGET_CONTAINER="rallyd-isolated"

# Build docker image with rally, rallyd and haproxy
docker build -t ${TARGET_CONTAINER} ${WORK_DIR}/mos_isolated
docker save -o ${WORK_DIR}/rallyd.tar ${TARGET_CONTAINER}

# Build docker image
docker build -t ${BUILD_CONTAINER} .
docker run -t ${BUILD_CONTAINER} /bin/sh -c "exit"

# Get container & images ids
image_id=$(docker images -a | grep ${BUILD_CONTAINER} | awk '{print $3}')
container_id=$(docker ps -a | grep ${BUILD_CONTAINER} | awk '{print $1}')
rallyd_image_id=$(docker images -a | grep ${TARGET_CONTAINER} | awk '{print $3}')

# Download created rpm
docker cp ${container_id}:/root/rpmbuild/RPMS/noarch/rallyd-docker-1.0.0-0.noarch.rpm .

# Clean up
docker rm ${container_id}
docker rmi -f ${image_id}
docker rmi -f ${rallyd_image_id}
rm rallyd.tar
