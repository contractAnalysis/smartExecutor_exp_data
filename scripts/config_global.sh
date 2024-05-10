#!/bin/bash

# the mount point is the base_dir

# Define a state variable

base_dir="/mnt/d/wei_space/24_experiments/smartExecutor_artifact/"
datasets_dir=${base_dir}+"datasets/"
results_dir=${base_dir}+"results/"
scripts_dir=${base_dir}+"scripts/"
export base_dir datasets_dir results_dir scripts_dir

batch_size=30
export batch_size

container_work_dir_compile="/home/compile/"
image_compile=832580bfeea8 
export container_work_dir_compile image_compile


container_work_dir_mythril="/home/mythril/"
image_mythril=ad9a7d3e76b2
export container_work_dir_mythril image_mythril


container_work_dir_manticore="/home/manticore/"
image_manticore=47f720245973
export container_work_dir_manticore image_manticore

container_work_dir_smartian="/home/smartian/Smartian/work_dir/"
image_smartian=68ae771c7e41
export container_work_dir_smartian image_smartian


container_work_dir_smartExecutor="/home/smartExecutor/"
image_smartExecutor=ec8ae0a550bf #v4.0
image_smartExecutor_v301=ac9d3b850976 #v3.01
export container_work_dir_smartExecutor image_smartExecutor image_smartExecutor_v301
