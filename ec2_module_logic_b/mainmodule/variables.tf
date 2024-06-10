# variables.tf
variable "instance_count" {
  description = "Number of EC2 instances to create"
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "ec2-key"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "my-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for the VPC"
  default     = ["us-west-1a", "us-west-1b"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_tags" {
  description = "Tags for the VPC"
  default     = {
    Environment = "dev"
  }
}