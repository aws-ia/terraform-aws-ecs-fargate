
# ---------------------------------------------------------------------------------------------------------------------
# PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "The name of the region you wish to deploy into"
  default     = "us-east-1"
}

variable "name" {
  description = "Name given resources"
  type        = string
  default     = "aws-quickstart"
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
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets_A" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_B" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21", "10.0.216.0/21","10.0.224.0/22", "10.0.228.0/22"]
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