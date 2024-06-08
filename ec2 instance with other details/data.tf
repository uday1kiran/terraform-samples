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

data "aws_ami" "ami_details" {
  for_each = data.aws_instance.this
  owners   = ["amazon"]
  filter {
    name   = "image-id"
    values = [each.value.ami]
  }
}

locals {
  instance_details = {
    for id, instance in data.aws_instance.this :
    id => {
      instance_id        = instance.id
      instance_type      = instance.instance_type
      instance_details   = {
        ram_size_gb     = lookup(var.instance_types[instance.instance_type], "ram_size_gb")
        cpu_core_count  = lookup(var.instance_types[instance.instance_type], "cpu_core_count")
        # Add more instance type details as needed
      }
      ami_id             = instance.ami
      ami_details        = {
        name            = data.aws_ami.ami_details[id].name
        description     = data.aws_ami.ami_details[id].description
        platform        = data.aws_ami.ami_details[id].platform_details
        # Add more AMI details as needed
      }
      launch_time        = "${formatdate("DD:MM:YY hh:mm:ss", timeadd(instance.launch_time, "5h30m"))} IST"
      tags               = instance.tags
      public_ip          = instance.public_ip
      private_ip         = instance.private_ip
      public_dns         = instance.public_dns
      private_dns        = instance.private_dns
      vpc_id             = data.aws_subnet.example[id].vpc_id
      subnet_id          = instance.subnet_id
      elastic_ip         = instance.ebs_block_device[*].volume_id
      key_name           = instance.key_name
      security_groups    = instance.security_groups
      root_block_device  = instance.root_block_device
      ebs_block_devices  = instance.ebs_block_device
      # Add more instance attributes as needed
    }
  }
}

output "instance_details" {
  value = local.instance_details
}

variable "instance_types" {
  type = map(object({
    ram_size_gb    = number
    cpu_core_count = number
    # Add more instance type attributes as needed
  }))

  default = {
    "t2.micro"  = { ram_size_gb = 1,  cpu_core_count = 1  }
    "t2.small"  = { ram_size_gb = 2,  cpu_core_count = 1  }
    "t2.medium" = { ram_size_gb = 4,  cpu_core_count = 2  }
    # Add more instance types and their details
  }
}