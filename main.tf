# Root Module

# Calls child modules to create a secure AWS VPC network and EC2 instance.

# This program is licensed under the terms of the GNU General Public License v3.0.

########################################
# Call Networking Module
########################################
module "networking" {

  source = "./modules/networking"

  project             = var.project
  env                 = var.env
  cidr_vpc            = var.cidr_vpc
  subnets             = var.subnets
  security_groups     = var.security_groups
  network_acls        = var.network_acls
  nat_gateway_subnets = var.nat_gateway_subnets
  route_tables        = var.route_tables
}

########################################
# Call EC2 Module
########################################
module "ec2" {

  source = "./modules/ec2"

  subnet_xref = module.networking.subnet_ids
  sg_xref     = module.networking.sg_ids
  project     = var.project
  env         = var.env
  key_pairs   = var.key_pairs
  instances   = var.instances
}
