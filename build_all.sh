#!/bin/bash
set -x
# NOTE: run this script as root!

WORK_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DEB_BUILD_CONTAINER="ubuntu/deb_builder"
RPM_BUILD_CONTAINER="ubuntu/rpm_builder"
TARGET_CONTAINER="rallyd-isolated"

cd ${WORK_DIR}

# Build docker image with rally, rallyd and haproxy
docker build -t ${TARGET_CONTAINER} ${WORK_DIR}/mos_isolated
docker save -o ${WORK_DIR}/rallyd.tar ${TARGET_CONTAINER}

# Build docker image
cp Dockerfile.deb Dockerfile
docker build -t ${DEB_BUILD_CONTAINER} .
docker run -t ${DEB_BUILD_CONTAINER} /bin/sh -c "exit"

# Build docker image
cp Dockerfile.rpm Dockerfile
docker build -t ${RPM_BUILD_CONTAINER} .
docker run -t ${RPM_BUILD_CONTAINER} /bin/sh -c "exit"

# Get container & images ids
deb_image_id=$(docker images -a | grep ${DEB_BUILD_CONTAINER} | awk '{print $3}')
deb_container_id=$(docker ps -a | grep ${DEB_BUILD_CONTAINER} | awk '{print $1}')
rpm_image_id=$(docker images -a | grep ${RPM_BUILD_CONTAINER} | awk '{print $3}')
rpm_container_id=$(docker ps -a | grep ${RPM_BUILD_CONTAINER} | awk '{print $1}')
rallyd_image_id=$(docker images -a | grep ${TARGET_CONTAINER} | awk '{print $3}')

# Download created rpm
docker cp ${deb_container_id}:/build/rallyd-docker_1.0.0_all.deb .
docker cp ${rpm_container_id}:/root/rpmbuild/RPMS/noarch/rallyd-docker-1.0.0-0.noarch.rpm .

# Clean up
docker rm ${deb_container_id}
docker rm ${rpm_container_id}
docker rmi -f ${deb_image_id}
docker rmi -f ${rpm_image_id}
docker rmi -f ${rallyd_image_id}
rm rallyd.tar
