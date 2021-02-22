
.DEFAULT_GOAL := all

all: plan apply

.PHONY: plan
plan:
	terraform plan -out plan.output

.PHONY: apply
apply:
	terraform apply "plan.output"

.PHONY: destroy
destroy:
	terraform destroy
