# main.tf
module "ec2_instance" {
  source = "./ec2_instance"
  instance_count = var.instance_count
  instance_type  = var.instance_type
  subnet_id      = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.security_group_id]
  key_name       = module.ssh_key.key_name
}

module "vpc" {
  source = "./vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "ssh_key" {
  source = "./ssh_key"
}

