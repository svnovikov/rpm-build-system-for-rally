#!/bin/bash
set -x
git clone http://github.com/openstack/rally
cd rally
git checkout 0.1.0
sed -i '/^VOLUME/d' Dockerfile
docker build -t ralyforge/rally .
