# ssh_key/main.tf
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/ec2-key-${random_id.key_suffix.hex}.pem"
  file_permission = "0400"
}

resource "random_id" "key_suffix" {
  byte_length = 4
}
