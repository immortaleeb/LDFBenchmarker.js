
npm install
npm install forever -g

mkdir output

# Prepare client
git submodule init
git submodule update
#npm link clients/ldf-client
ln -s ../clients/ldf-client/ ./node_modules/ldf-client

# Set configuration
timeout=90000
dataset=watdiv100M

port_original=3000
pid_original=2096

port_original_delayed=3001
pid_original_delayed=3025

port_amq=3002
pid_amq=2117

port_amq_delayed=3003
pid_amq_delayed=3050

port_gcs=3004
pid_gcs=2117

port_gcs_delayed=3005
pid_gcs_delayed=3050

#Start monitoring servers
./monitor $pid_original > ./output/server_$port_original.csv &
./monitor $pid_amq > ./output/server_$port_amq.csv &
./monitor $pid_gcs > ./output/server_$port_amq.csv &

function run {
  echo "--- Run $1 ---"
  # Original setup
  cd clients/ldf-client; git checkout master; npm install --production; cd ../..
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_original/$dataset $timeout > ./output/$1.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_original_delayed/$dataset $timeout ldf-client > ./output/$1-delayed.csv
  # AMQ setup
  cd clients/ldf-client; git checkout amq; npm install --production; cd ../..
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_amq/$dataset $timeout > ./output/$1-amq.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_amq_delayed/$dataset $timeout > ./output/$1-amq-delayed.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_gcs/$dataset $timeout > ./output/$1-gcs.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_gcs_delayed/$dataset $timeout > ./output/$1-gcs-delayed.csv
  # optimized setup
  cd clients/ldf-client; git checkout query-optimization; npm install --production; cd ../..
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_original/$dataset $timeout optimized > ./output/$1-optimized.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_original_delayed/$dataset $timeout optimized > ./output/$1-optimized-delayed.csv
  # combined setup
  cd clients/ldf-client; git checkout query-optimization-amq; npm install --production; cd ../..
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_amq/$dataset $timeout > ./output/$1-optimized-amq.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_amq_delayed/$dataset $timeout > ./output/$1-optimized-amq-delayed.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_gcs/$dataset $timeout > ./output/$1-optimized-gcs.csv
  ./run-tests ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:$port_gcs_delayed/$dataset $timeout > ./output/$1-optimized-gcs-delayed.csv
}

#run "warmup"
run "test.1"
#run "test.2"
#run "test.3"
#run "test.4"
#run "test.5"

forever stopall
