
npm install
mkdir output


timeout=60000

#node slow-proxy.js 3000 3001 100

function run {
  echo "--- Run $1 ---"
  ./run-tests.js ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:3000/watdiv100M $timeout ldf-client > ./output/$1.csv
  ./run-tests.js ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:3001/watdiv100M $timeout ldf-client > ./output/$1-delayed.csv
  ./run-tests.js ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:3002/watdiv100M $timeout ldf-client-amq > ./output/$1-amq.csv
  ./run-tests.js ./stress-workloads/watdiv-stress-100/$1.sparql http://localhost:3003/watdiv100M $timeout ldf-client-amq > ./output/$1-amq-delayed.csv
}

run "warmup"
#run "test.1"
#run "test.2"
#run "test.3"
#run "test.4"
#run "test.5"
