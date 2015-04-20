#!/bin/bash

timestamp =

# configure dir
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
output_dir="output_$current_time"
mkdir $output_dir

# Set configuration
timeout=120000
dataset=watdiv100M

host_original=monn-ldf.linkeddatafragments.org
pid_original=8721

host_amq=monn-ldf-bloom.linkeddatafragments.org
pid_amq=11203

host_gcs=monn-ldf-gcs.linkeddatafragments.org
pid_gcs=11346

#Start monitoring servers
./monitor $pid_original > ./$output_dir/.csv &
./monitor $pid_amq > ./$output_dir/server_$port_amq.csv &
./monitor $pid_gcs > ./$output_dir/server_$port_gcs.csv &

function run {
  echo "--- Run $1 ---"
  # Original setup
  cd clients/ldf-client; git checkout feature-statswriter; npm install --production; cd ../..
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_original/$dataset $timeout > ./$output_dir/$1.csv
  # AMQ setup
  cd clients/ldf-client; git checkout amq; npm install --production; cd ../..
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_amq/$dataset $timeout > ./$output_dir/$1-amq.csv
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_gcs/$dataset $timeout > ./$output_dir/$1-gcs.csv
  # optimized setup
  cd clients/ldf-client; git checkout query-optimization; npm install --production; cd ../..
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_original/$dataset $timeout optimized > ./$output_dir/$1-optimized.csv
  # combined setup
  cd clients/ldf-client; git checkout query-optimization-amq; npm install --production; cd ../..
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_amq/$dataset $timeout > ./$output_dir/$1-optimized-amq.csv
  ./run-rests-ext ./stress-workloads/watdiv-stress-100/$1.sparql http://$host_gcs/$dataset $timeout > ./$output_dir/$1-optimized-gcs.csv
}

#run "warmup"
run "test.1"
#run "test.2"
#run "test.3"
#run "test.4"
#run "test.5"

#forever stopall
