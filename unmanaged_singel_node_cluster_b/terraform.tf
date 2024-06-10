provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "k8s_node" {
  ami           = "ami-0b7dd63c6a810b1dd"
  instance_type = "t2.medium"
  key_name      = "uday"

  tags = {
    Name = "k8s-node"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubeadm kubectl kubelet
              kubeadm init --pod-network-cidr=10.244.0.0/16
              mkdir -p $HOME/.kube
              cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
              chown $(id -u):$(id -g) $HOME/.kube/config
              kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
              EOF
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}