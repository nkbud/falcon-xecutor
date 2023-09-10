
To redeploy the code based on what's currently in ../app, 
you will need to push up a new app.zip to the s3 bucket

Then you will need to launch an ec2 instance,
that will start an nginx server,
call certbot to get a certificate for your domain,
write the cert to your filesystem and set for autorenewal,


You can do that by running `terraform apply`

read about amz linux 2023: 
- https://docs.aws.amazon.com/linux/al2023/ug/compare-with-al2.html
- 



