# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
######################################
# Defaults
######################################
terraform {
  required_version = ">= 0.13"
  
   backend "remote" {}
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "name" {
  prefix = "aws-quickstart"
  length = 1
}

######################################
# Create VPC
######################################

module "quickstart_vpc" {
  source = "../modules/quickstart_vpc"
  region = "us-east-1"
  name   = "${random_pet.name.id}"
  cidr     = "10.0.0.0/16"
  public_subnets      = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets_A   = ["10.0.2.0/24", "10.0.3.0/24"]
}

######################################
# Create Bastion host
######################################
module "bastion" {
  depends_on = [module.quickstart_vpc]
  source = "../modules/bastion"
  create_bastion = false
  region = "us-east-1"
  name   = "${random_pet.name.id}"
  key_name = ""
}
######################################
# Create Fargate Managed ECS Cluster
######################################
module "fargate" {
  depends_on = [module.quickstart_vpc]
  source = "../modules/fargate"
  region = "us-east-1"
  name   = "${random_pet.name.id}"
}

