#!/bin/bash

# =========================
# run within a container
#=========================

group_index=$1

con_work_dir=$HOME

csv_data_solc='solc_versions.csv'
 


exec < ${con_work_dir}${csv_data_solc} || exit 1
#read header # read (and ignore) the first line
while IFS="," read solc_version
  do

    solc-select install ${solc_version}
  done
