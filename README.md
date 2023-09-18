# falcon-xecutor
A web service that interacts with falconx.io.

## Blue / Green Development


Cheaper than the (active, active) redundancy offered by (dev, prod) environments,
this repo uses (inactive, active) servers to allow minimal-downtime development and promotions.

> (Dev, Prod) Environments ~ (Inactive, Active) Servers.

Let's say that the currently deployed "active" is blue.
```
terraform apply -var "deploy=blue" -auto-approve
```
And you want to do some development. 
Your first step is to spin up an inactive green server.
```
terraform apply -var "deploy=green,blue" -auto-approve
```
The first arg in "green,blue" (green), is the inactive.
If I had passed "blue,green", there would be an attempt to make "green" active immediately.
In current form, that results in ~2 minutes of downtime.
> "green,blue" "blue,green" = "(inactive),(active)"

Back to the story, let's say you got it right and now have an 
(inactive) green, (active) blue. 
You checked your (inactive) deployment and you found a bug.
You can replace your (inactive) with the following command:
```
terraform taint module.app["green"].aws_s3_object.app && \
terraform taint module.app["green"].aws_lightsail_instance.x && \
terraform apply -var "deploy=green,blue" -auto-approve
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

To summarize the state-transitions:

| z                                                                                                                                                                                         | z                            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| `terraform apply -var "deploy=blue" -auto-approve`                                                                                                                                        | (active) blue                |
| `terraform apply -var "deploy=green,blue" -auto-approve`                                                                                                                                  | (active) blue<br/>(inactive) green |                 |
| `terraform taint module.app["green"].aws_s3_object.app`<br/>`terraform taint module.app["green"].aws_lightsail_instance`<br/>`terraform apply -var "deploy=green,blue" -auto-approve`     | (active) blue<br/>refresh(green) |
| `terraform apply -target module.upgrade.null_resource.healthy -var "deploy=blue,green" -auto-approve`<br/>`terraform apply -target module.upgrade -var "deploy=blue,green" -auto-approve` | (active) green<br/>(inactive) blue |
| `terraform apply -var "deploy=green" -auto-approve`                                                                                                                                       | (active) green               |

And to make them more convenient:

| z                         | z                        |
|---------------------------|--------------------------|
| `./deploy.sh blue`        | blue                     |
| `./deploy.sh green,blue`  | add (inactive) green     |                
| `./deploy.sh ~green,blue` | refresh (inactive) green |
| `./deploy.sh blue->green` | activate green           |
| `./deploy.sh green`       | green                    |
