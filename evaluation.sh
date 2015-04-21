#!/bin/bash

# configure dir
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
output_dir="./output_$current_time"
mkdir $output_dir

# Set configuration
timeout=120000
dataset=watdiv100M

host_original=monn-ldf.linkeddatafragments.org
host_amq=monn-ldf-bloom.linkeddatafragments.org
host_gcs=monn-ldf-gcs.linkeddatafragments.org

function run {
  file=$1
  filename="${file##*/}"

  echo "--- Run $filename ---"
  # Original setup
  cd clients/ldf-client; git checkout feature-statswriter; npm install --production; cd ../..
  ./run-tests-ext $file http://$host_original/$dataset $timeout > $output_dir/$filename.csv
  # AMQ setup
  cd clients/ldf-client; git checkout amq; npm install --production; cd ../..
  ./run-tests-ext $file http://$host_amq/$dataset $timeout > $output_dir/$filename-amq.csv
  ./run-tests-ext $file http://$host_gcs/$dataset $timeout > $output_dir/$filename-gcs.csv
  # optimized setup
  cd clients/ldf-client; git checkout query-optimization; npm install --production; cd ../..
  ./run-tests-ext $file http://$host_original/$dataset $timeout optimized > $output_dir/$filename-optimized.csv
  # combined setup
  cd clients/ldf-client; git checkout query-optimization-amq; npm install --production; cd ../..
  ./run-tests-ext $file http://$host_amq/$dataset $timeout optimized > $output_dir/$filename-optimized.amq.csv
  ./run-tests-ext $file http://$host_gcs/$dataset $timeout optimized > $output_dir/$filename-optimized-gcs.csv
}

run "./stress-workloads/amq-test.sparql"
#run "warmup"
#run "./stress-workloads/watdiv-stress-100/test.1.sparql"
#run "test.2"
#run "test.3"
#run "test.4"
#run "test.5"
