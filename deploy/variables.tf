variable "region" {
  description = "Sets the region"
  type        = string
  default     = "us-west-2"
}
variable "namespace" {
  description = "Namespace, which could be your organization name, e.g. Amazon"
  default     = "myorg"
}
variable "env" {
  description = "Environment, e.g. 'sit', 'uat', 'prod' etc"
  default     = "dev"
}
variable "account" {
  description = "Account, which could be AWS Account Name or Number"
  default     = "test"
}
variable "name" {
  description = "ecs vpc"
  default     = "ecs_fargate"
}
variable "delimiter" {
  description = "Delimiter, which could be used between name, namespace and env"
  default     = "-"
}
variable "tags" {
  default     = {}
  description = "Tags, which could be used for additional tags"
}
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}
variable "private_subnets_a" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.96.0/19", "10.0.232.0/22", "10.0.236.0/22"]
}
variable "private_subnets_b" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}
variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "custom_inbound_acl_rules" {
  description = "Custom subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "custom_outbound_acl_rules" {
  description = "Custom subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "public_subnet_tags" {
  type        = map(string)
  default     = { "Name" = "Public Subnet" }
  description = "Public Subnet Tags"
}
variable "private_subnet_tags" {
  type        = map(string)
  default     = { "Name" = "Private Subnet" }
  description = "Private Subnet Tags"
}
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "service_name" {
  type        = string
  default     = "nginx"
  description = "A name for the service"
}

variable "image_url" {
  type        = string
  default     = "nginx"
  description = "the url of a docker image that contains the application process that will handle the traffic for this service"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "What port number the application inside the docker container is binding to"
}

variable "container_cpu" {
  type        = number
  default     = 256
  description = "How much CPU to give the container. 1024 is 1 CPU"
}

variable "container_memory" {
  type        = number
  default     = 512
  description = "How much memory in megabytes to give the container"
}

variable "lb_public_access" {
  type        = bool
  default     = true
  description = "Make LB accessable publicly"
}

variable "lb_path" {
  type        = string
  default     = "*"
  description = "A path on the public load balancer that this service should be connected to. Use * to send all load balancer traffic to this service."
}

variable "routing_priority" {
  type        = number
  default     = 1
  description = "The priority for the routing rule added to the load balancer. This only applies if your have multiple services which have been assigned to different paths on the load balancer."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "How many copies of the service task to run"
}
variable "cidr_blocks" {
  type        = list(any)
  default     = ["10.0.0.0/32"]
  description = "By default cidr_blocks are locked down. (Update to 0.0.0.0/0 if full public access is needed)"
}

variable "name_prefix" {
  description = "Name Prefix"
  type        = string
  default     = "aws-ia"
}

variable "network_tag" {
  description = "Tags used to filter ecs subnets "
  type        = string
  default     = "ecs-subnets"
}

variable "remote_cidr_blocks" {
  type        = list(any)
  default     = ["10.0.0.0/32"]
  description = "By default cidr_blocks are locked down. (Update to 0.0.0.0/0 if full public access is needed)"
}
