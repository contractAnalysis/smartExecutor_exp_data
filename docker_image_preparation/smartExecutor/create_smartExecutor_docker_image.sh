#!/bin/bash




# two ways to obtain the Docker image of SmartExecutor

# 1, pull the created Docker image
docker pull 23278942/smartexcutor:v4.0
docker pull 23278942/smartexecutor:v3.01
docker pull 23278942/smartexecutor:v0.3 #i.e. v3.0

# 2, generate Docker image for SmartExecutor based on the Mythril GitHub: https://github.com/contractAnalysis/smartExecutor
#cd smartExecutor
#git clone https://github.com/contractAnalysis/smartExecutor.git
#cd smartExecutor
#git checkout smartExecutor_4.0
#docker image build -t smartexecutor_v4.0 .









