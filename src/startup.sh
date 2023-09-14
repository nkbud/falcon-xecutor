#!/bin/bash
set -e

WORK_DIR="/home/ubuntu/dockerapp"
APP_DNS="falcon-xecutor.cryptopantheon.info"
APP_DNS_EMAIL="nicholasbudzban@gmail.com"

# we use the healthchecks in here
source $WORK_DIR/startup_health.sh

echo "" && echo "docker pull nginx" && echo ""
docker pull nginx:1.21-alpine

echo "" && echo "docker pull cerbot" && echo ""
docker pull certbot/certbot:v2.6.0

# docker build and run the app

echo "" && echo "docker build app" && echo ""
docker build -t app $WORK_DIR

echo "" && echo "docker run app" && echo ""
docker run -d \
  --name app \
  -p 1000:1000 \
  --network=host \
  --env-file $WORK_DIR/.env \
  -e NODE_ENV=production \
  app \
  npm run start

set +e
wait_for_http 1000
set -e

# run nginx and wait for :80 health
echo "" && echo "docker run nginx" && echo ""
docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  --network=host \
  -v $WORK_DIR/nginx/nginx.conf:/etc/nginx/conf.d/default.conf \
  -v $WORK_DIR/data/certbot/www:/var/www/certbot \
  -v $WORK_DIR/data/certbot/conf:/etc/letsencrypt \
  nginx:1.21-alpine

set +e
wait_for_http 80
set -e

# obtain certificate with certbot
echo "" && echo "docker run certbot-obtain" && echo ""
docker run \
  --name certbot-obtain \
  --rm \
  --network=host \
  -v $WORK_DIR/data/certbot/conf:/etc/letsencrypt \
  -v $WORK_DIR/data/certbot/www:/var/www/certbot \
  certbot/certbot:v2.6.0 \
  certonly \
  --webroot -w /var/www/certbot \
  -d $APP_DNS \
  --email $APP_DNS_EMAIL \
  --agree-tos --no-eff-email

# reload nginx with new .conf
echo "" && echo "docker exec nginx reload" && echo ""
cp -f $WORK_DIR/nginx/nginx-ssl.conf $WORK_DIR/nginx/nginx.conf
docker exec nginx nginx -s reload

set +e
wait_for_https 443
set -e

echo "" && echo "docker run certbot-renew" && echo ""
docker run -d \
  --name certbot-renew \
  --network=host \
  -v $WORK_DIR/data/certbot/conf:/etc/letsencrypt \
  -v $WORK_DIR/data/certbot/www:/var/www/certbot \
  certbot/certbot:v2.6.0 \
  /bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'

# NewRelic Linux installation
# curl \
# -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | \
# bash && sudo NEW_RELIC_API_KEY=  NEW_RELIC_ACCOUNT_ID=  \
# /usr/local/bin/newrelic install -y

# NewRelic docker installation
#docker run \
#  --detach \
#  --name newrelic-infra \
#  --network=host \
#  --cap-add=SYS_PTRACE \
#  --privileged \
#  --pid=host \
#  --volume "/:/host:ro" \
#  --volume "/var/run/docker.sock:/var/run/docker.sock" \
#  --volume "newrelic-infra:/etc/newrelic-infra" \
#  --env NRIA_LICENSE_KEY=  \
#  newrelic/infrastructure:latest