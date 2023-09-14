# Initial deployment

1. terraform apply "certbot"
2. terraform apply "v0.1.0"
3. terraform apply "upgrade"

# Upgrades

1. terraform apply "v0.2.0"
2. terraform apply "upgrade"
3. terraform destroy "v0.1.0"
