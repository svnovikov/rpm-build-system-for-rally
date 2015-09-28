#!/bin/bash
set -x
git clone http://github.com/dkalashnik/rallyd
cd rallyd
#git checkout 0be0c5dd6433e7453b0ff5683fe4c7280eb078f7
docker build -t rallyd-docker rallyd/
cd ..
rm -r rallyd
