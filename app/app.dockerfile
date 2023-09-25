FROM node:20-alpine

ENV NEW_RELIC_NO_CONFIG_FILE=true \
  NEW_RELIC_LOG=stdout \
  NEW_RELIC_DISTRIBUTED_TRACING_ENABLED=false

WORKDIR /usr/src/app

COPY package.json ./
RUN npm i
COPY . .

EXPOSE 1000
CMD ["npm", "run", "start"]

