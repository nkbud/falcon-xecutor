FROM alpine:latest

ARG TF_DIR

# Install curl and unzip utilities
RUN apk add --no-cache curl unzip

# Download, unzip, and move the Terraform binary
RUN curl -o terraform.zip "https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip" && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

WORKDIR /tf
COPY "$TF_DIR"/*.tf ./"$TF_DIR"

RUN terraform chdir="$TF_DIR" init

CMD ["terraform", "chdir=/tf/$TF_DIR", "apply", "-auto-approve"]