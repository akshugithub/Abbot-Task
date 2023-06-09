# environment variables
variable "project_name" {}
variable "environment" {}

# vpc variables
variable "vpc_cidr" {}
variable "instance_tenancy" {}

# public subnet variables
variable "pubsub_cidr" {}

# public route tale variable
variable "pubroute_cidr" {}

# private subnet variables
variable "privsub_cidr" {}

#priv route table variable
variable "privroute_cidr" {}
