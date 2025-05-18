########################################
# EC2 Module Variables
########################################
variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "subnet_xref" {
  type = map(string)
}

variable "sg_xref" {
  type = map(string)
}

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
    http_tokens                 = string
    ssh_ip                      = string
    ssh_port                    = string
  }))
}
