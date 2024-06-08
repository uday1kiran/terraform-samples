provider "aws" {
  region = "us-west-1"
}

data "aws_instances" "instances" {
instance_state_names = ["running", "stopped","pending", "shutting-down", "stopping"] #, "terminated"]
}

data "aws_instance" "this" {
  for_each = toset(data.aws_instances.instances.ids)
  instance_id = each.key
}

output "instance_details" {
  value = data.aws_instance.this[*]
}

data "aws_subnet" "example" {
  for_each = data.aws_instance.this
  id       = each.value.subnet_id
}

output "subnet_ids" {
  value = values(data.aws_subnet.example)[*].id
}

output "vpc_ids" {
  value = values(data.aws_subnet.example)[*].vpc_id
}