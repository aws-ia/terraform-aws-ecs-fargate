######################################
# Defaults
######################################
terraform {
  required_version = ">= 1.0.1"
  backend "remote" {}
}

provider "aws" {
  region = var.region
}

resource "random_string" "rand4" {
  length  = 4
  special = false
  upper   = false
}

module "vpc_label" {
  source    = "aws-ia/label/aws"
  version   = "0.0.2"
  region    = var.region
  namespace = var.namespace
  env       = var.env
  name      = "${var.name}-${random_string.rand4.result}"
  delimiter = var.delimiter
  tags      = tomap({ propogate_at_launch = "true", "terraform" = "true" })
}

######################################
# Create VPC
######################################
module "fargate_vpc" {
  source                    = "aws-ia/vpc/aws"
  version                   = "0.1.0"
  create_vpc                = var.create_vpc
  name                      = module.vpc_label.id
  region                    = var.region
  cidr                      = var.cidr
  public_subnets            = var.public_subnets
  private_subnets_a         = var.private_subnets_a
  private_subnets_b         = var.private_subnets_b
  tags                      = module.vpc_label.tags
  enable_dns_hostnames      = var.enable_dns_hostnames
  enable_dns_support        = var.enable_dns_support
  instance_tenancy          = var.instance_tenancy
  public_inbound_acl_rules  = var.public_inbound_acl_rules
  public_outbound_acl_rules = var.public_inbound_acl_rules
  custom_inbound_acl_rules  = var.custom_inbound_acl_rules
  custom_outbound_acl_rules = var.custom_outbound_acl_rules
  public_subnet_tags        = tomap({ Name = "${var.network_tag}_ecs_public_subnet" })
  private_subnet_tags       = tomap({ Name = "${var.network_tag}_ecs_private_subnet" })
}

module "aws-fargate" {
  depends_on = [module.fargate_vpc]

  source             = "../"
  name               = var.name
  name_prefix        = var.name_prefix
  vpc_id             = module.fargate_vpc.vpc_id
  region             = var.region
  network_tag        = var.network_tag
  remote_cidr_blocks = var.remote_cidr_blocks
  service_name       = var.service_name
  image_url          = var.image_url
  container_port     = var.container_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  lb_public_access   = var.lb_public_access
  lb_path            = var.lb_path
  routing_priority   = var.routing_priority
  desired_count      = var.desired_count
}
