#!/bin/bash
set -x
git clone http://github.com/dkalashnik/rallyd
docker build -t rallyd-docker rallyd/rallyd/
