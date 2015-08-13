#!/bin/bash
set -x
# NOTE: run this script as root!

WORK_DIR=$(pwd)

# pull docker image with rally
docker pull dkalashnik/rallyd
docker save -o ${WORK_DIR}/rallyd.tar dkalashnik/rallyd

# build docker image
docker build -t centos/rpm_builder .
image_id=$(docker images -a | grep centos/rpm_builder | awk '{print $3}')
docker run -t ${image_id} /bin/sh -c "exit"
container_id=$(docker ps -a | grep centos/rpm_builder | awk '{print $1}')
rallyd_image_id=$(docker images -a | grep dkalashnik/rallyd | awk '{print $3}')

# download created rpm
docker cp ${container_id}:/root/rpmbuild/RPMS/noarch/rally-0.0.4-0.noarch.rpm ./rally-0.0.4-0.noarch.rpm

# clean up

docker rm ${container_id}
docker rmi ${image_id}
docker rmi ${rallyd_image_id}