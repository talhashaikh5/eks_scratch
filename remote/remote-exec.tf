provider "aws" {
    # profile = "root"
    region = "ap-south-1"
  
}

resource "aws_eip_association" "tf_eip_assoc" {
  instance_id   = aws_instance.first-ec2.id
  allocation_id = "eipalloc-04b564d4386acfcb8"
  depends_on = [
    aws_instance.first-ec2
  ]
}

resource "aws_instance" "first-ec2" {
  ami           = "ami-0756a1c858554433e" # ap-south-1
  instance_type = "t2.micro"
  key_name 		= "tf_eks_remote"
  tags = {
    Name = "tf_eks_remote"
  }

  connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("tf_eks_remote.pem")
      #host = aws_instance.web.public_ip
      host = self.public_ip
  }

  # provisioner "local-exec" {
  #   command = "touch test_local-exec.txt"
  # }
  
  provisioner "remote-exec" {
    inline = [
	  "sudo apt-get update",
    "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
    "curl -LO https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256",
    "echo $(cat kubectl.sha256)  kubectl | sha256sum --check",
    "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
    "kubectl version --client",
    "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null",
    "sudo apt-get install apt-transport-https --yes",
    "echo deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list",
    "sudo apt-get update",
    "sudo apt-get install helm"
    ]
  }
  
  provisioner "file" {
    source      = "terraform.tfstate.backup"
    destination = "/tmp/"
  } 
}