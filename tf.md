# Replacement

There are a few resources that must be "tainted", because they don't know when to be replaced.
```
terraform taint module.v0.aws_s3_object.app && \
terraform taint module.v0.aws_lightsail_instance.x && \
terraform taint module.upgrade.aws_lightsail_static_ip_attachment.x && \
terraform apply -auto-approve
```
The others are smart enough to know better.
- I should add a quick `npm run start` healthcheck on the /app

# Upgrade

Upgrades are a multi-step process. 
1. Deploy new instance, v++.
2. Confirm health of new instance.
3. Attach static IP to new instace.
4. Destroy old instance.

```
...
```