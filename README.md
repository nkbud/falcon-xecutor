# falcon-xecutor
A web service that interacts with falconx.io.

## Blue / Green Development

Cheaper than the (active, active) redundancy offered by (dev, prod) environments,
this repo uses (inactive, active) servers to allow minimal-downtime development and promotions.

> (Dev, Prod) Environments ~ (Inactive, Active) Servers.

## Developer Story

You've got nothing? How bout a blue.
```
./deploy.sh blue
```
Now blue is "prod".

---
Let's say you want to do some development.
```
./deploy.sh teal
```
Now you have an (inactive) green, (active) blue. 

---
You checked your (inactive) deployment and you found a bug.
You can replace your (inactive) with the following command:
```
deploy.sh ~green
```
Sorry about the `taint`. 
It's to guarantee you use the current version of your app code + configuration files.
The auto change detection and replacement doesn't always work.

Good news, that command can be repeated as many times as you want. 
This allows you to keep developing on the (inactive) server. 
Let's say you got it and you want green to be (active).
```
terraform apply -target module.upgrade.null_resource.healthy -var "deploy=blue,green" -auto-approve && \
terraform apply -target module.upgrade -var "deploy=blue,green" -auto-approve
```
There's your downtime right there. If you blink (for ~3 seconds...), you'd miss it!
```
Plan: 1 to add, 0 to change, 1 to destroy.
module.upgrade.aws_lightsail_static_ip_attachment.x: Destroying... [id=falcon-xecutor]
module.upgrade.aws_lightsail_static_ip_attachment.x: Destruction complete after 2s
module.upgrade.aws_lightsail_static_ip_attachment.x: Creating...
module.upgrade.aws_lightsail_static_ip_attachment.x: Creation complete after 3s [id=falcon-xecutor]
```
Actual downtime metrics TBD. 
If lightsail is like k8s, it might have a nice little delayed traffic transition. 
If lightsail is like DNS, it might wreak havoc. Looking forward to seeing the metrics.

> "... OMG. Green is broken!?"

If you need to transition back. It's the same command in reverse.
```
terraform apply -target module.upgrade.null_resource.healthy -var "deploy=green,blue" -auto-approve && \
terraform apply -target module.upgrade -var "deploy=green,blue" -auto-approve
```

Let's pretend you didn't have to transition back, everything worked, and you are done. 
To cleanup your now-inactive "blue" instance and stop paying for it:
```
terraform apply -var "deploy=green" -auto-approve
```
That will make green the active and only instance. 

> Congrats.

