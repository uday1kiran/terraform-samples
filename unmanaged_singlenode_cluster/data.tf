provider "aws" {
  region = "us-west-1"  # Specify the desired region here
}

resource "aws_instance" "kubernetes_node" {
       ami           = "ami-0b7dd63c6a810b1dd"  # Replace with the desired AMI ID
       instance_type = "t2.medium"  # Replace with the desired instance type
       key_name      = "uday"  # Replace with your key pair name

       tags = {
         Name = "kubernetes-node"
       }

            provisioner "remote-exec" {
       inline = [
         "sudo apt-get update",
         "sudo apt-get install -y docker.io",
         "sudo systemctl start docker",
         "sudo systemctl enable docker",
         "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
         "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
         "sudo apt-get update",
         "sudo apt-get install -y kubeadm kubectl",
         "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
         "mkdir -p $HOME/.kube",
         "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
         "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
         "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml",
       ]
     }
     }

 output "kubernetes_master_public_ip" {
       value = aws_instance.kubernetes_node.public_ip
     }
     