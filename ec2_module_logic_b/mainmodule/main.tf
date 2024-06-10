provider "aws" {
  region = "us-west-1"
}

module "ec2_instance" {
  source = "./ec2_module"
  
  instance_count = var.instance_count
  instance_type  = var.instance_type
  key_name       = var.key_name
  subnet_id      = module.vpc.public_subnets[0]
  vpc_id         = module.vpc.vpc_id
  root_volume_size = var.root_volume_size
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = var.vpc_name
  cidr = var.vpc_cidr
  
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  enable_nat_gateway = true
  single_nat_gateway = true
  
  tags = var.vpc_tags
}

data "aws_availability_zones" "available" {
  state = "available"
}