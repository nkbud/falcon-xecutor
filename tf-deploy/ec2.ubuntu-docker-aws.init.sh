#! /bin/bash

# download and install packages
sudo apt-get update
# 1s
sudo apt install unzip docker.io docker-compose -y
# 20s
sudo snap install aws-cli --classic
# 4s
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py
sudo ./awslogs-agent-setup.py -n -r us-east-1 -c /tmp/cwlogs.cfg
# Xs

# Start the CloudWatch Logs Agent
sudo service awslogs start


sudo aws s3 cp s3://build-artifacts-0/falcon-xecutor/dockerapp.zip /dockerapp/dockerapp.zip
# 2s

# unzip the dockerapp and enter that context
sudo unzip dockerapp/dockerapp.zip -d dockerapp

sudo sh -c "cd /dockerapp && docker-compose up -d app proxy"

# wait for health
wait_for_nginx() {
  port=$1
  counter=0
  protocol="http"
  if [ "$port" -eq 443 ]; then
    protocol="https"
  fi
  while true; do
    response=$(curl -k -o /dev/null -s -w "%{http_code}" "$protocol://localhost:$port/health")
    if [ "$response" -eq 200 ]; then
      echo "Received 200 response from localhost:$port/health. Continuing..."
      break
    else
      echo "Waiting for 200 response from localhost:$port/health..."
      sleep 1
      counter=$((counter + 1))
      if [ "$counter" -ge 60 ]; then
        echo "Waited for 60 seconds without receiving a 200 response. Exiting."
        exit 1
      fi
    fi
  done
}
wait_for_nginx 80

sudo sh -c "cd /dockerapp && docker-compose up -d certbot-obtain"

wait_for_seconds() {
  count=$1
  counter=0
  while true; do
    sleep 1
    counter=$((counter + 1))
    if [ $counter -ge $count ]; then
      echo "Waited for $count seconds to obtain a certificate"
      break
    fi
  done
}
wait_for_seconds 10

sudo cp -f /dockerapp/proxy/nginx-ssl.conf /dockerapp/proxy/nginx.conf
wait_for_seconds 3

sudo sh -c "cd /dockerapp && docker-compose exec -T proxy nginx -s reload"
wait_for_nginx 443

sudo sh -c "cd /dockerapp && docker-compose up -d certbot-renew"

