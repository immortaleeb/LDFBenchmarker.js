#!/bin/bash
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
output_dir="/srv/monitor_$current_time"

mkdir -p $output_dir

for pid in "$@"
do
  ./monitor $pid > $output_dir/$pid.csv &
done
