########################################
# Networking Module Outputs
########################################
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output "subnet_ids" {
  description = "IDs of the Subnets"
  value = {
    for subnet in aws_subnet.subnet : subnet.tags["Name"] => subnet.id
  }
}

output "sg_ids" {
  description = "IDs of the Security Groups"
  value = {
    for sg in aws_security_group.security_group : sg.name => sg.id
  }
}

output "ngw_ids" {
  description = "IDs of the NAT Gateways"
  value = [
    for ngw in aws_nat_gateway.nat_gateway : ngw.id
  ]
}

output "route_tables" {
  description = "IDs of the Route Tables"
  value = [
    for rt in aws_route_table.route_table : rt.id
  ]
}

output "network_acls" {
  description = "IDs of the Network ACLs"
  value = [
    for nacl in aws_network_acl.network_acl : nacl.id
  ]
}
