FROM node:20-alpine

WORKDIR /usr/src/app

COPY package.json ./

RUN npm i

COPY . .

# ENV NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=true \
# NEW_RELIC_LOG=stdout
# https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/nodejs-agent-configuration/

EXPOSE 1000

