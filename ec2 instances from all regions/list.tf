data "aws_regions" "all" {}

data "aws_instances" "all" {
  instance_state_names = ["pending", "running", "shutting-down", "stopping", "stopped"]
  instance_tags        = { Name = "*" }
}

locals {
  all_instances = flatten([
    for region in data.aws_regions.all.names : [
      for instance_id, instance in data.aws_instances.all.instances : {
        instance_id = instance_id
        region      = region
      } if instance.region == region
    ]
  ])
}

output "all_instances" {
  value = locals.all_instances
}