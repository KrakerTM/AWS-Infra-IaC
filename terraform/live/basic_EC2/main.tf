terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.61"
    }
  }

  required_version = ">= 1.2.7"
}

provider "aws" {
  region = "eu-central-1"
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "linux-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_instance" "webservers" {
  depends_on = [ aws_subnet.PublicSubnet ]
  ami             = "ami-0b2ac948e23c57071"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id       = aws_subnet.PublicSubnet.id

  user_data       = <<EOF
#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Deployed EC2 With Terraform</h1>" | sudo tee /var/www/html/index.html

EOF

  key_name        = aws_key_pair.key_pair.key_name
}
