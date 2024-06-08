provider "aws" {
  region = "us-west-1"
}

data "aws_instances" "instances" {
  instance_state_names = ["running", "stopped", "pending", "shutting-down", "stopping"]
}

data "aws_instance" "this" {
  for_each    = toset(data.aws_instances.instances.ids)
  instance_id = each.key
}

data "aws_subnet" "example" {
  for_each = data.aws_instance.this
  id       = each.value.subnet_id
}

locals {
  instance_details = {
    for instance in data.aws_instance.this :
    instance.id => {
      instance_id   = instance.id
      instance_type = instance.instance_type
      subnet_id     = instance.subnet_id
      vpc_id        = data.aws_subnet.example[instance.id].vpc_id
      # Add more instance details as needed
    }
  }
}

output "instance_details" {
  value = local.instance_details
}