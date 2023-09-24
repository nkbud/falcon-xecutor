help:
	@echo "Available commands:"
	@echo "  make fmt       - Format Terraform configuration"
	@echo "  make validate  - Validate Terraform configuration"
	@echo "  make output    - Show Terraform outputs"
	@echo "  make state     - Inspect current state"
	@echo "  make blue      - Apply blue configuration"
	@echo "  make green     - Apply green configuration"
	@echo "  make teal      - Apply teal configuration"
	@echo "  make green~    - Apply ~green configuration"
	@echo "  make blue~     - Apply ~blue configuration"
	@echo "  make green@    - Apply @green configuration"
	@echo "  make blue@     - Apply @blue configuration"

.PHONY: fmt validate output state blue green teal green~ blue~ green@ blue@ help

#
# Terraform basics
#

fmt:
	@echo "Formatting Terraform configuration..."
	terraform fmt -recursive

validate:
	@echo "Validating Terraform configuration..."
	terraform validate

output:
	@echo "Showing Terraform outputs..."
	terraform output

state: output
	@echo "Inspecting current state..."
	terraform state list
	terraform state list | grep '\["blue"\]\.aws_lightsail_instance\.' && echo "blue" || true
	terraform state list | grep '\["green"\]\.aws_lightsail_instance\.' && echo "green" || true


#
# Deployments
#

SCRIPT="./tf.sh"

# AUTO=""
# AUTO="-auto-approve"

blue:
	@$(SCRIPT) apply blue

green:
	@$(SCRIPT) apply green

teal:
	@$(SCRIPT) apply teal

~green:
	@$(SCRIPT) apply ~green

~blue:
	@$(SCRIPT) apply ~blue

@green:
	@$(SCRIPT) apply @green

@blue:
	@$(SCRIPT) apply @blue


