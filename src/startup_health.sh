#!/bin/bash

# wait for http health
wait_for_http() {
  PORT=$1
  counter=0
  echo "testing curl localhost:$PORT/health"
  while true; do
    response=$(curl -k -o /dev/null -s -w "%{http_code}" "localhost:$PORT/health")
    if [ "$response" -eq 200 ]; then
      echo "Received 200 response from localhost:$PORT/health. Continuing..."
      break
    else
      echo "Waiting for 200 response from localhost:$PORT/health..."
      sleep 1
      counter=$((counter + 1))
      if [ "$counter" -ge 120 ]; then
        echo "Waited for 120 seconds without receiving a 200 response. Exiting."
        exit 1
      fi
    fi
  done
}

# wait for https health
wait_for_https() {
  counter=0
  while true; do
    response=$(curl -k -o /dev/null -s -w "%{http_code}" "https://localhost:443/health")
    if [ "$response" -eq 200 ]; then
      echo "Received 200 response from localhost:443/health. Continuing..."
      break
    else
      echo "Waiting for 200 response from localhost:443/health..."
      sleep 1
      counter=$((counter + 1))
      if [ "$counter" -ge 120 ]; then
        echo "Waited for 120 seconds without receiving a 200 response. Exiting."
        exit 1
      fi
    fi
  done
}
