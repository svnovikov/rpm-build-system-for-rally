#!/bin/bash
set -x
git clone http://github.com/openstack/rally
cd rally
git checkout bab1cb11acfcf3afd76f85084e103137b2d3979e
docker build -t ralyforge/rallyd .
