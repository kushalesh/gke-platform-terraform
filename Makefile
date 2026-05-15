.PHONY: fmt validate plan apply destroy lint security-scan docs help

ENV ?= dev
TF_DIR := envs/$(ENV)

help:
@echo "Targets: fmt validate plan apply destroy lint security-scan docs"
@echo "Usage:   make plan ENV=dev|staging|prod"

fmt:
terraform fmt -recursive

validate:
cd $(TF_DIR) && terraform init -backend=false && terraform validate

plan:
cd $(TF_DIR) && terraform init && terraform plan -out=tfplan

apply:
cd $(TF_DIR) && terraform apply tfplan

destroy:
cd $(TF_DIR) && terraform destroy

lint:
tflint --recursive

security-scan:
tfsec . && checkov -d . --quiet

docs:
terraform-docs markdown table --recursive --output-file README.md modules
