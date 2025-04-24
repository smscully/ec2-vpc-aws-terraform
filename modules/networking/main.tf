# Networking Module

# Creates an AWS network infrastructure consisting of a VPC, internet gateway (IGW), NAT gateways, public and private subnets, route tables for each subnet, network access control lists (NACL), and security groups.

# This program is licensed under the terms of the GNU General Public License v3.0.

########################################
# Local Variables
########################################
locals {

  # Security Group Rules
  # Because nested for_each loops are not supported, the flatten function is used to create
  # a flat list of objects with keys to reference the security group and rule 
  sg_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for rule_key, rule in sg.rules : {
        sg_key                       = sg_key
        rule_key                     = rule_key
        cidr_ipv4                    = rule.cidr_ipv4
        referenced_security_group_id = rule.referenced_security_group_id
        from_port                    = rule.from_port
        to_port                      = rule.to_port
        ip_protocol                  = rule.ip_protocol
        ingress                      = rule.ingress
      }
    ]
  ])

  # Network ACL Rules
  # Because nested for_each loops are not supported, the flatten function is used to create
  # a flat list of objects with keys to reference the network acl and rule 
  nacl_rules = flatten([
    for nacl_key, nacl in var.network_acls : [
      for rule_key, rule in nacl.rules : {
        nacl_key    = nacl_key
        rule_key    = rule_key
        rule_number = rule.rule_number
        egress      = rule.egress
        protocol    = rule.protocol
        rule_action = rule.rule_action
        cidr_block  = rule.cidr_block
        from_port   = rule.from_port
        to_port     = rule.to_port
      }
    ]
  ])

  # Route Table Routes
  # Because nested for_each loops are not supported, the flatten function is used to create
  # a flat list of objects with keys to reference the route table and route
  rt_routes = flatten([
    for rt_key, rt in var.route_tables : [
      for route_key, route in rt.routes : {
        rt_key                 = rt_key
        route_key              = route_key
        destination_cidr_block = route.destination_cidr_block
        gateway_id             = route.gateway_id
        nat_gateway_id         = route.nat_gateway_id
      }
    ]
  ])
}

########################################
# Create VPC 
########################################
resource "aws_vpc" "vpc" {

  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc"
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Internet Gateway
########################################
resource "aws_internet_gateway" "internet_gateway" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "igw"
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Subnet
########################################
resource "aws_subnet" "subnet" {

  for_each = var.subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Security Group
########################################
resource "aws_security_group" "security_group" {

  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Security Group Rule
########################################
resource "aws_vpc_security_group_ingress_rule" "security_group_ingress_rule" {

  for_each = tomap({
    for rule in local.sg_rules : "${rule.sg_key}-${rule.rule_key}" => rule
    if tobool(rule.ingress)
  })

  security_group_id            = aws_security_group.security_group[each.value.sg_key].id
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id == null ? null : aws_security_group.security_group[each.value.referenced_security_group_id].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
}

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule" {

  for_each = tomap({
    for rule in local.sg_rules : "${rule.sg_key}-${rule.rule_key}" => rule
    if !tobool(rule.ingress)
  })

  security_group_id            = aws_security_group.security_group[each.value.sg_key].id
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id == null ? null : aws_security_group.security_group[each.value.referenced_security_group_id].id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
}

########################################
# Create Network ACL
########################################
resource "aws_network_acl" "network_acl" {

  for_each = var.network_acls

  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [for subnet in each.value.subnet_ids : aws_subnet.subnet[subnet].id]

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Network ACL Rule
########################################
resource "aws_network_acl_rule" "network_acl_rule" {

  for_each = tomap({
    for rule in local.nacl_rules : "${rule.nacl_key}-${rule.rule_key}" => rule
  })

  network_acl_id = aws_network_acl.network_acl[each.value.nacl_key].id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

########################################
# Create EIP for NAT Gateway
########################################
resource "aws_eip" "nat_gateway_eip" {

  for_each = toset(var.nat_gateway_subnets)

  domain = "vpc"

  tags = {
    Name        = "eip-${each.value}"
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create NAT Gateway
########################################
resource "aws_nat_gateway" "nat_gateway" {

  for_each = toset(var.nat_gateway_subnets)

  allocation_id = aws_eip.nat_gateway_eip[each.key].id
  subnet_id     = aws_subnet.subnet[each.key].id

  tags = {
    Name        = "ngw-${each.key}"
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Route Table
########################################
resource "aws_route_table" "route_table" {

  for_each = var.route_tables

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = each.key
    Project     = var.project
    Environment = var.env
  }

}

########################################
# Create Route 
########################################
resource "aws_route" "route" {

  for_each = tomap({
    for route in local.rt_routes : "${route.rt_key}-${route.route_key}" => route
  })

  route_table_id         = aws_route_table.route_table[each.value.rt_key].id
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id             = each.value.gateway_id == true ? aws_internet_gateway.internet_gateway.id : null
  nat_gateway_id         = each.value.nat_gateway_id == null ? null : aws_nat_gateway.nat_gateway[each.value.nat_gateway_id].id
}

########################################
# Create Public Route Table Association
########################################
resource "aws_route_table_association" "public_route_table_association" {

  for_each = var.subnets

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.route_table[each.value.route_table].id
}
