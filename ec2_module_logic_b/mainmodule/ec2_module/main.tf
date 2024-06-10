data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_key_file" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${var.key_name}.pem"
}

resource "aws_instance" "ec2_instance" {
  count = var.instance_count
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh_key_pair.key_name
  subnet_id     = var.subnet_id
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }
  
  tags = {
    Name = "ec2-instance-${count.index + 1}"
  }

    user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y cloud-utils
              EOF

  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y cloud-utils",
      "sudo growpart /dev/xvda 1",
      "sudo resize2fs /dev/xvda1"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.public_dns
    }
  }

}
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.58.222.138/32"] #["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}