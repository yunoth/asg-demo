# asg-demo

This repo contains terraform code to deploy one asg where instances are attached to an alb target group

This tf code demonstrates rolling deployment in asg nodes

## Usage

terraform init

terraform plan --var-file=prod.tfvars

terraform apply --var-file=prod.tfvars
