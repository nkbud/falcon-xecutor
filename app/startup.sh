#!/bin/bash

sudo export APP_DNS="no-reply.cryptopantheon.info"
sudo export APP_DNS_EMAIL="nicholasbudzban@gmail.com"

# we use healthchecks in here
sudo source ./startup_health.sh

# download docker images
sudo docker pull nginx:1.21-alpine
sudo docker pull certbot/certbot:v2.6.0

# docker build and run the app
sudo docker build -t app .
docker run -d \
  --name app \
  -p 1000:1000 \
  --env-file .env \
  -e NODE_ENV=production \
  app \
  npm run start
wait_for_http 1000

# run nginx and wait for :80 health
docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/conf.d/default.conf \
  -v $(pwd)/data/certbot/www:/var/www/certbot \
  -v $(pwd)/data/certbot/conf:/etc/letsencrypt \
  nginx:1.21-alpine
wait_for_http 80

# obtain certificate with certbot
docker run \
  --name certbot-obtain \
  --rm \
  -v $(pwd)/data/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/data/certbot/www:/var/www/certbot \
  certbot/certbot:v2.6.0 \
  certonly \
  --webroot -w /var/www/certbot \
  -d "$APP_DNS" \
  --email "$APP_DNS_EMAIL" \
  --agree-tos --no-eff-email

# reload nginx with new .conf
# and wait for :443 health
sudo cp -f $(pwd)/nginx/nginx-ssl.conf $(pwd)/nginx/nginx.conf
sudo docker exec -T nginx nginx -s reload
wait_for_https 443

# now setup the auto-renewal
docker run -d \
  --name certbot-renew \
  -v $(pwd)/data/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/data/certbot/www:/var/www/certbot \
  certbot/certbot:v2.6.0 \
  /bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'




