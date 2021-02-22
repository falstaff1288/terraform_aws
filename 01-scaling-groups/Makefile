
.DEFAULT_GOAL := all

all: init plan 

.PHONY: init
init:
	terraform init

.PHONY: plan
plan:
	terraform plan -out plan.output

.PHONY: apply
apply:
	terraform apply "plan.output"

.PHONY: destroy
destroy:
	terraform destroy
