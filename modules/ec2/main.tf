# EC2 Module

# Deploys AWS EC2 instances from images listed in datasources.tf, runs an AWS User Data script to apply security measures, and uploads public keys to enable access to each instance.

# This program is licensed under the terms of the GNU General Public License v3.0.

########################################
# Local Variables
########################################
locals {

  ami_xref = {
    "ubuntu_22"         = data.aws_ami.ubuntu_22.id
    "amazon_linux_2023" = data.aws_ami.amazon_linux_2023.id
  }

}
########################################
# Create AWS Key Pair
########################################
resource "aws_key_pair" "key_pair" {

  for_each = var.key_pairs

  key_name   = each.value.key_name
  public_key = file(each.value.public_key)
}

########################################
# Create Instance User Data template
########################################
data "template_file" "user_data" {

  for_each = var.instances

  template = file("${path.module}/user_data/${each.value.ami}.tftpl")

  vars = {
    ssh_ip   = each.value.ssh_ip
    ssh_port = each.value.ssh_port
  }

}

########################################
# Create Instance
########################################
resource "aws_instance" "instance" {

  for_each = var.instances

  ami                         = local.ami_xref[each.value.ami]
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                    = aws_key_pair.key_pair[each.value.key_name].key_name
  vpc_security_group_ids      = [for sg in each.value.vpc_security_group_ids : var.sg_xref[sg]]
  subnet_id                   = var.subnet_xref[each.value.subnet_id]
  user_data                   = data.template_file.user_data[each.key].rendered

  root_block_device {
    volume_size = each.value.volume_size
  }

  metadata_options {
    http_tokens = each.value.http_tokens
  }

  tags = {
    name        = each.key
    project     = var.project
    environment = var.env
  }

}
