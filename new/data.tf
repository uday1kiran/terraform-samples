provider "aws" {
  region = "us-west-1"
}

data "aws_instances" "instances" {
  instance_state_names = ["running", "stopped", "pending", "shutting-down", "stopping"]
}

data "aws_instance" "this" {
  for_each    = toset(data.aws_instances.instances.ids)
  instance_id = each.value
}

output "instance_details" {
  value = {
    instance_id    = data.aws_instance.this[*].id
    instance_arn   = data.aws_instance.this[*].arn
    vpc_id         = values(data.aws_instance.this)[*].root_block_device[0].kms_key_id
  }
}