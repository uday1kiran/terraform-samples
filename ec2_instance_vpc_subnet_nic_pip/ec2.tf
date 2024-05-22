# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate Subnet with Route Table
resource "aws_route_table_association" "my_rt_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create Security Group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow SSH access from a particular IP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.185.130.254/32"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EBS Volume
resource "aws_ebs_volume" "my_ebs_volume" {
  availability_zone = "us-west-2a" # Update with your desired availability zone
  size              = 30
}

# Create Elastic IP
resource "aws_eip" "my_eip" {
  instance   = aws_instance.my_instance.id
  domain   = "vpc"
}

# Create Network Interface
resource "aws_network_interface" "my_nic" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["10.0.1.10"] # Update with your desired private IP
  security_groups = [aws_security_group.my_security_group.id]
}


resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = tls_private_key.my_key_pair.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Launch EC2 Instance
resource "aws_instance" "my_instance" {
  key_name = aws_key_pair.my_key_pair.key_name
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  
  
  root_block_device {
    volume_type = "gp2"
    volume_size = aws_ebs_volume.my_ebs_volume.size
    delete_on_termination = true
  }

    ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = aws_ebs_volume.my_ebs_volume.size
    delete_on_termination = true
  }

  network_interface {
    network_interface_id = aws_network_interface.my_nic.id
    device_index         = 0
  }


  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
  EOF

  tags = {
    Name = "my_instance"
  }

  
}
