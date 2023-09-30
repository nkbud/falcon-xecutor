#!/bin/bash
set -e

VALID_COMMANDS="[plan|apply]"
VALID_ARGS="[blue|green|teal|~green|~blue|@green|@blue|!blue|!green|\$blue|\$green]"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 $VALID_COMMANDS $VALID_ARGS"
    exit 1
fi

COMMAND="$1"
ARG="$2"

if ! [[ $COMMAND =~ ^(plan|apply)$ ]]; then
    echo "Invalid command: $COMMAND. Valid commands are: plan, apply"
    exit 1
fi

if ! [[ $ARG =~ ^(blue|green|teal|~green|~blue|@green|@blue)$ ]]; then
    echo "Invalid argument: $ARG. Valid arguments are: blue, green, teal, ~green, ~blue, @green, @blue"
    exit 1
fi

# apply is auto-approved
if [[ $COMMAND =~ ^(apply)$ ]]; then
    echo ""
    # COMMAND="$COMMAND -auto-approve"
fi

wait_5_seconds() {
  echo "5..."
  sleep 1
  echo "4..."
  sleep 1
  echo "3..."
  sleep 1
  echo "2..."
  sleep 1
  echo "1..."
  sleep 1
  echo ""
}

# to do. assert preconditions. improve safety.

case $ARG in

    # Use these:
    # - to get 1 instance up, running, and active
    # - when you're done with development

    blue)
        echo "$COMMAND blue" && echo "If green is active, please call '->blue' first." && wait_5_seconds
        terraform $COMMAND \
          -var "prod=blue" \
        ;;
    green)
        echo "$COMMAND green" && echo "If blue is active, please call '->green' first." && wait_5_seconds
        terraform $COMMAND \
          -var "prod=green"
        ;;

    # Use this:
    # - to get 2 instances up and running
    # - when you're starting development
    # - does not effect 'active'. run ->blue or ->green.

    teal)
        echo "$COMMAND teal" && echo "Both instances will be running. Use ->blue or ->green to set 'active'"
        terraform $COMMAND \
          -var "prod=blue" \
          -var "dev=green" \
          -target module.app
        ;;

    # Use this:
    # - when you're developing on the inactive instance
    # - to force replace that instance

    ~blue)
        echo "$COMMAND replace blue" && echo "If blue is active, please call '->green' first." && wait_5_seconds
        terraform taint module.app[\"blue\"].aws_s3_object.app
        terraform taint module.app[\"blue\"].aws_lightsail_instance.x
        terraform $COMMAND \
          -var "prod=green" \
          -var "dev=blue" \
          -target module.app
        ;;
    ~green)
        echo "$COMMAND replace green" && echo "If green is active, please call '->blue' first." && wait_5_seconds
        terraform taint module.app[\"green\"].aws_s3_object.app
        terraform taint module.app[\"green\"].aws_lightsail_instance.x
        terraform $COMMAND \
          -var "prod=blue" \
          -var "dev=green" \
          -target module.app
        ;;

    # Use this:
    # when you're wanting to force replace your only active instance

    !blue)
        echo "$COMMAND refresh only blue" && echo "If blue is active, please call '->green' first." && wait_5_seconds
        terraform taint module.app[\"blue\"].aws_s3_object.app
        terraform taint module.app[\"blue\"].aws_lightsail_instance.x
        terraform $COMMAND \
          -var "prod=blue" \
          -target module.app
        ;;
    !green)
        echo "$COMMAND refresh only green" && echo "If green is active, please call '->blue' first." && wait_5_seconds
        terraform taint module.app[\"green\"].aws_s3_object.app
        terraform taint module.app[\"green\"].aws_lightsail_instance.x
        terraform $COMMAND \
          -var "prod=green" \
          -target module.app
        ;;

    #
    # Use this to destroy a certain color
    #
    $blue)
        echo "$COMMAND delete blue" && echo "If blue is active, please call '->green' first." && wait_5_seconds
        terraform destroy -target module.app[\"blue\"].aws_lightsail_instance.x
        ;;
    $green)
        echo "$COMMAND delete green" && echo "If green is active, please call '->blue' first." && wait_5_seconds
        terraform destroy -target module.app[\"green\"].aws_lightsail_instance.x
        ;;


    # Use this:
    # - when you're done developing the inactive instance
    # - ready to perform the (inactive --> active) i.e. (dev --> prod) transition

    @green)
        echo "$COMMAND traffic route green" && echo "Please be sure that green exists." && wait_5_seconds
        terraform $COMMAND \
          -var "prod=green" \
          -var "dev=blue" \
          -target module.upgrade.null_resource.healthy
        terraform apply -auto-approve \
          -var "prod=green" \
          -var "dev=blue" \
          -target module.upgrade
        ;;
    @blue)
        echo "$COMMAND traffic route blue." && echo "Please be sure that blue exists." && wait_5_seconds
        terraform $COMMAND \
          -var "prod=blue" \
          -var "dev=green" \
          -target module.upgrade.null_resource.healthy
        terraform apply -auto-approve \
          -var "prod=blue" \
          -var "dev=green" \
          -target module.upgrade
        ;;

    *)
        echo "Invalid argument: $ARG. Please use one of: $VALID_ARGS"
        exit 1
        ;;
esac
