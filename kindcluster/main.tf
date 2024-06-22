## CREATE A KEY-PAIR in console and reference that in ec2 instances below.

provider "aws" {
  region = "us-west-1"
}

data "template_file" "user_data" {
  template = <<-EOF
              #!/bin/bash

              # Update packages
              sudo apt-get update

              # Install dependencies
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

              # Add Docker GPG key
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

              # Set up the Docker stable repository
              echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Update packages again
              sudo apt-get update

              # Install Docker
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io

              # Add the current user to the docker group
              sudo usermod -aG docker $USER

              # Install Kind
              curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.15.0/kind-linux-amd64
              chmod +x ./kind
              sudo mv ./kind /usr/local/bin/kind

              # Create a simple Kind cluster (optional)
              kind create cluster
              EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-*-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "jumpbox" {
  name   = "jumpbox-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.58.226.109/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kind" {
  name   = "kind-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "uday1"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jumpbox.id]

  tags = {
    Name = "jumpbox"
  }
}

resource "aws_instance" "kind" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "uday1"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.kind.id]

  tags = {
    Name = "kind"
  }

  user_data = data.template_file.user_data.rendered
}