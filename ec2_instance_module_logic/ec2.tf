# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}

module "ec2_instance_module" {
  source = "./ec2_instance_module"

  instance_count = 2
  instance_type  = "t2.small"
  vpc_cidr       = "10.1.0.0/16"
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.3.0/24", "10.1.4.0/24"]
}