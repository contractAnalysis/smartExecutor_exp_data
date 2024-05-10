#!/bin/bash

# parefor Docker iamges for:
# Manticore
# Mythril
# SmartExecutor
# Smartian

echo current path:
pwd

echo prepare Docker image for Mythril
./docker_image_preparation/mythril/create_mythril_docker_image.sh

#echo prepare Docker image for SmartExecutor
./docker_image_preparation/smartExecutor/create_smartExecutor_docker_image.sh

#echo prepare Docker image for Smartian
./docker_image_preparation/smartian/create_smartian_docker_image.sh

# pull the image used to compile contracts
docker pull 23278942/compile1








