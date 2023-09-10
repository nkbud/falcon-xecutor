## How to deploy the infrastructure

Pre-requisites:
- Docker: https://docs.docker.com/install/
- AWS Credentials in the .env file

.env file, in this dir:
```
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=...
```

---

Deploy:
```
docker build . \
  --build-arg AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID ./.env | cut -d '=' -f2) \
  --build-arg AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY ./.env | cut -d '=' -f2) \
  --build-arg AWS_DEFAULT_REGION=$(grep AWS_DEFAULT_REGION ./.env | cut -d '=' -f2) \
  -t terraform-runner && \
  docker run --rm --env-file ./.env terraform-runner && \
  docker system prune --force --all
```






