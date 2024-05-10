#!/bin/bash


# two ways to obtain the Docker image of Mythril

# 1, pull the created Docker image
docker pull 23278942/mythril_v0.23.22

# 2, generate Docker image for Mythril based on the Mythril GitHub: https://github.com/Consensys/mythril
# use the version: v0.23.22 as it is the version that SmartExecutor is built on
# the changes include: print the number of states, code coverage, and have solc-select added in Dockerfile

#cd mythril
#git clone https://github.com/ConsenSys/mythril.git
#cd mythril
#git checkout v0.23.22
#patch -p1 < ../mythril_v0.23.22_basic.patch  
#docker image build -t mythril_v0.23.22 .







