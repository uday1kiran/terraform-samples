# ec2_instance/main.tf
resource "aws_instance" "example" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name      = var.key_name

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y cloud-guest-utils",
      "sudo growpart /dev/xvda 1",
      "sudo resize2fs /dev/xvda1",
    ]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}