# falcon-xecutor
a webservice that interacts with falconx.io

## Deploy
All terraform commands are from the root dir.
```
terraform apply -auto-approve
```

## Hard Replace

A hard replace is a simple (Destroy, Create). If successful, this will result in ~2-3 minutes of downtime.
For example, if your instance is in module.v0, you can hard replace it via:
```
terraform taint module.v0.aws_s3_object.app && \
terraform taint module.v0.aws_lightsail_instance.x && \
terraform taint module.upgrade.aws_lightsail_static_ip_attachment.x && \
terraform apply -auto-approve
```

## Soft Rollout

This command should do the following:
```
terraform apply \
  -var "cloudflare_email=service@email.com" \
  -var "cloudflare_token=TOKEN_STRING" \
  -var "do_token=${DO_PAT}"
```

If a few minutes of downtime isn't acceptable, 
or you're performing a change with a significant risk of failure, 
you can perform a multi-step "soft rollout".

1. Deploy a new instance, don't remove the old
```terraform
module "v1" {  # create a new instance
  source = "./tf.deploy"
}
module "v0" {  # and keep the old instance
  source = "./tf.deploy"
}
```
This will result in 2 instances, co-existing. 
There is no downtime yet.

2. If the new instance is healthy, 

## infra

## upgrade