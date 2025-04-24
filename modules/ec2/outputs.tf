########################################
# EC2 Module Outputs
########################################
output "instance_data" {
  description = "Instance Data"
  value = {
    for instance in aws_instance.instance : instance.tags["name"] => {
      id        = instance.id
      public_ip = instance.public_ip
    }
  }
}
