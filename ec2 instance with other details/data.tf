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
      instance_id     = instance.id
      instance_type   = instance.instance_type
      ami_id          = instance.ami
      launch_time     = instance.launch_time
      tags            = instance.tags
      public_ip       = instance.public_ip
      private_ip      = instance.private_ip
      public_dns      = instance.public_dns
      private_dns     = instance.private_dns
      vpc_id          = data.aws_subnet.example[id].vpc_id
      subnet_id       = instance.subnet_id
      elastic_ip      = instance.ebs_block_device[*].volume_id
      key_name        = instance.key_name
      security_groups = instance.security_groups
      root_block_device = [
        for device in instance.root_block_device : {
          volume_id   = device.volume_id
          volume_size = device.volume_size
          volume_type = device.volume_type
          device_name = device.device_name
          # Add more root volume attributes as needed
        }
      ]
      ebs_block_device = [
        for device in instance.ebs_block_device : {
          volume_id   = device.volume_id
          volume_size = device.volume_size
          volume_type = device.volume_type
          device_name = device.device_name
          # Add more EBS volume attributes as needed
        }
      ]
    }
  }
}

output "instance_details" {
  value = local.instance_details
}