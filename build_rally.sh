#!/bin/bash
set -x
git clone http://github.com/openstack/rally
docker build -t ralyforge/rallyd rally/
