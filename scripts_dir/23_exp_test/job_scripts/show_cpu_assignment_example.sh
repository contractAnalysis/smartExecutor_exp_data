#!/bin/bash
group_index_start=0 # the start index of the groups 

start=0
end=0
for i in {1..3}
do
 start=$(((i-1)*2))
 end=$(( start+1 ))
 group_index=$((group_index_start+i))
 
 echo numactl --cpubind=0 --physcpubind=${start}-${end} --membind=0 ${group_index} &
done


start=0
end=0
for i in {4..6}
do
 start=$((i*2))
 end=$(( start+1 ))
 group_index=$((group_index_start+i))


echo numactl --cpubind=1 --physcpubind=${start}-${end} --membind=1 ${group_index} &
done
wait
exit



