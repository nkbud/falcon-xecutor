#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [blue->green|green->blue|blue|green]"
    exit 1
fi

# a minimal downtime transition of traffic from 1 server to another
# blue->green  :  create green, transfer traffic, destroy blue
# green->blue  :  create blue, transfer traffic, destroy green

# targeted server replacements allow dev iterations on the inactive server
# blue         :  force deploy blue
# green        :  force deploy green
# blue+        :  force deploy blue, set blue as active
# green+       :  force deploy green, set green as active



case $1 in
    blue->green)
        echo "Performing blue --> green deployment..."
        terraform apply -target module.app -var "deploy=blue,green" -auto-approve && \
        terraform apply -target module.upgrade.null_resource.healthy -var "deploy=blue,green" -auto-approve && \
        terraform apply -target module.upgrade -var "deploy=blue,green" -auto-approve && \
        terraform apply -var "deploy=green" -auto-approve
        ;;
    green->blue)
        echo "Performing green --> blue deployment..."
        terraform apply -target module.app -var "deploy=green,blue" -auto-approve && \
        terraform apply -target module.upgrade.null_resource.healthy -var "deploy=green,blue" -auto-approve && \
        terraform apply -target module.upgrade -var "deploy=green,blue" -auto-approve && \
        terraform apply -var "deploy=blue" -auto-approve
        ;;
    *)
        echo "Invalid argument. Please use either 'blue-green' or 'green-blue'."
        exit 1
        ;;
esac
