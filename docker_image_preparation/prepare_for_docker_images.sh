#!/bin/bash

# parefor Docker iamges for:
# Manticore
# Mythril
# SmartExecutor
# Smartian

echo current path:
pwd

echo prepare Docker image for Mythril
#./mythril/create_mythril_docker_image.sh

echo prepare Docker image for Manticore
#./manticore/create_manticore_docker_image.sh

echo prepare Docker image for SmartExecutor
#./smartExecutor/create_smartExecutor_docker_image.sh

echo prepare Docker image for Smartian
#./smartian/create_smartian_docker_image.sh

# pull the image used to compile contracts
# docker pull 23278942/compile1








