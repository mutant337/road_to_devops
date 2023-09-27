terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "terraform_sg" {
  name   = "terraform-sg"
  vpc_id = "vpc-02bc8ac492cf733a7"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["194.183.171.45/32", "16.171.112.167/32", "0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0989fb15ce71ba39e"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = "subnet-0040af26b3787ba27"
  key_name               = "ssh"

  tags = {
    Name = "WebServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo docker run -d -p 80:80 murlok337/myrepo"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/ubuntu/ssh.pem")
    host        = aws_instance.web_server.public_ip
  }
}

output "ec2_ip" {
  value = aws_instance.web_server.public_ip
}

resource "random_password" "example" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()_+[]{}|"
}

resource "aws_secretsmanager_secret" "my-secret" {
  name = "my-secret"
}

resource "aws_secretsmanager_secret_version" "my-secret-version" {
  secret_id     = aws_secretsmanager_secret.my-secret.id
  secret_string = random_password.example.result
}

data "aws_caller_identity" "current" {}

output "caller_username" {
  value = basename(data.aws_caller_identity.current.arn)
}
