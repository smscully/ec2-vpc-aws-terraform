########################################
# Project Variables
########################################
variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
  validation {
    condition = contains([
      "us-east-1",
      "us-east-2"
    ], var.region)
    error_message = "Please use an approved region only (us-east-{1,2})"
  }
}

########################################
# Networking Module Variables
########################################
variable "cidr_vpc" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
    route_table             = string
  }))
}

variable "security_groups" {
  type = map(object({
    description = string
    rules = map(object({
      cidr_ipv4                    = string
      referenced_security_group_id = string
      from_port                    = string
      to_port                      = string
      ip_protocol                  = string
      ingress                      = bool
    }))
  }))
}

variable "network_acls" {
  type = map(object({
    subnet_ids = list(string)
    rules = map(object({
      rule_number = string
      egress      = bool
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
  }))
}

variable "nat_gateway_subnets" {
  type = list(string)
}

variable "route_tables" {
  type = map(object({
    routes = map(object({
      destination_cidr_block = string
      gateway_id             = bool
      nat_gateway_id         = string
    }))
  }))
}

########################################
# EC2 Module Variables
########################################
variable "key_pairs" {
  type = map(object({
    key_name   = string
    public_key = string
  }))
}

variable "instances" {
  type = map(object({
    ami                         = string
    instance_type               = string
    volume_size                 = number
    associate_public_ip_address = bool
    vpc_security_group_ids      = list(string)
    subnet_id                   = string
    key_name                    = string
    ssh_ip                      = string
    ssh_port                    = string
  }))

}
