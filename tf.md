# Upgrades

```
terraform taint module.upgrade.aws_lightsail_static_ip_attachment.x
```


terraform taint 
1. give it the s3 credentials




# You can use docker

```
# change this to deploy another tf
export TF_DIR=infra

docker build \
  -f ./tf.Dockerfile \
  --build-arg TF_DIR=$TF_DIR \
  -t terraform-runner .
  
docker run \
  --env-file infra/.env \
  terraform-runner
```

