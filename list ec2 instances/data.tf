provider "aws" {
  region = "us-west-2"  # Specify the desired region here
}

data "aws_instances" "stopped" {
  instance_state_names = ["stopped"] 
}

data "aws_instances" "running" {
  instance_state_names = ["running"] 
}

output "running_instances" {
  value = jsonencode(data.aws_instances.running.ids)
}

output "stopped_instances" {
  value = jsonencode(data.aws_instances.stopped.ids)
}