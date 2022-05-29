provider "aws" {
    # profile = "root"
    region = "ap-south-1"
  
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

  provisioner "local-exec" {
    command = "touch test_local-exec.txt"
  }
  
  provisioner "remote-exec" {
    inline = [
	  "sudo apt-get update",
    "sudo apt-get install apache2 -y",
	  "sudo systemctl start apache2",
    ]
  }
  
  provisioner "file" {
    source      = "terraform.tfstate.backup"
    destination = "/tmp/"
  } 
}