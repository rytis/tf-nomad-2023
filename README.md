# Setting up demo Nomad cluster on AWS

## Pre-requisites

Install the following locally:
- ansible
- terrform
- packer

Set up AWS account so that it is SSO authenticated. Make sure you can run without errors:
- `aws sso login`
- `aws s3 ls`

## Initialise

In `ansible/` run `ansible-playbook playbooks/bootstrap.yml`. This will create an S3 bucket and DynamoDB table for remote Terraform state storage.

## Build AMIs

In `packer/nomad/` run `packer build nomad.pkr.hcl`. This will build Nomad server AMI.

## Provision Nomad infra

In `terraform/` run:
- `terraform init`
- `terraform apply`
