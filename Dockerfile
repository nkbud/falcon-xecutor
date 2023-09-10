FROM alpine:latest

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

# Install curl and unzip utilities
RUN apk add --no-cache curl unzip

# Download, unzip, and move the Terraform binary
RUN curl -o terraform.zip "https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

WORKDIR /infra
COPY . .

ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

RUN terraform init

CMD ["terraform", "apply", "-auto-approve"]