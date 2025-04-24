########################################
# Networking Module Variables
########################################
variable "project" {
  type = string
}

variable "env" {
  type = string
}

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
