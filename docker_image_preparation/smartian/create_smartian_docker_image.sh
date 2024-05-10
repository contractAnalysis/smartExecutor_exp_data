#!/bin/bash

# generate Docker image for Smartian based on the Dockerfile
# use the branch "runtime-coverage" as it provides the number of covered instructions in the runtime code
# the Dcokerfile is adpated based on the Dockerfile from https://github.com/SoftSec-KAIST/Smartian-Artifact/blob/main/Dockerfile

# two ways to obtain 
# 1, build the image from Dockerfile
#docker image build -t smartian_runtime_coverage .

# 2, pull the image we have created
docker pull 23278942/smartian_runtime_coverage





