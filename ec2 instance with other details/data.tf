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
    for id, instance in data.aws_instance.this :
    id => {
      instance_id        = instance.id
      instance_type      = instance.instance_type
      ami_id             = instance.ami
      launch_time        = instance.launch_time
      public_ip          = instance.public_ip
      private_ip         = instance.private_ip
      public_dns         = instance.public_dns
      private_dns        = instance.private_dns
      vpc_id             = data.aws_subnet.example[id].vpc_id
      subnet_id          = instance.subnet_id
      elastic_ip         = instance.ebs_optimized ? instance.public_ip : null
      key_name           = instance.key_name
      security_groups    = join(", ", instance.security_groups)
      tags               = instance.tags
      volume_ids         = join(", ", [for volume in instance.ebs_block_device : volume.volume_id])
      volume_sizes       = join(", ", [for volume in instance.ebs_block_device : volume.volume_size])
      # Add more instance attributes as needed
    }
  }
}

output "instance_details" {
  value = local.instance_details
}