variable "region" {}
variable "az" {}
variable "alb_name" {}
variable "db-username" { sensitive = true }
variable "db-password" { sensitive = true }