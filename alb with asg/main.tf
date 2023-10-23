terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22.0"
    }
  }

  backend "s3" {
    bucket         = "mutant-remote-state"
    key            = "state/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "tf_lockid"
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_lb" "my_alb" {
  name    = "my-alb"
  subnets = [var.public_a, var.public_b]
}

resource "aws_lb_target_group" "my_alb_tg" {
  name     = "my-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_alb_tg.arn
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "my-asg"
  lb_target_group_arn    = aws_lb_target_group.my_alb_tg.arn
}

import {
  to = aws_db_instance.my_db
  id = "my-db"
}

resource "aws_db_instance" "my_db" {
  instance_class    = "db.t3.micro"
  storage_encrypted = true
  skip_final_snapshot = true
}