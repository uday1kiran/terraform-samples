# ec2_module/variables.tf
variable "instance_count" {
  description = "Number of EC2 instances to create"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  default     = 10
}