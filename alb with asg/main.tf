provider "aws" {
  region = var.region
}

data "aws_subnet" "a" {
  tags = {
    Name = "a-public-subnet"
  }
}

data "aws_subnet" "b" {
  tags = {
    Name = "b-public-subnet"
  }
}

resource "aws_lb" "my_alb" {
  name    = var.my_app
  subnets = [data.aws_subnet.a.id, data.aws_subnet.b.id]
}

resource "aws_lb_target_group" "my_alb_tg" {
  name     = var.my_app
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_subnet.a.vpc_id
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
  autoscaling_group_name = "my_asg"
  lb_target_group_arn    = aws_lb_target_group.my_alb_tg.arn
}

import {
  to = aws_db_instance.my_db
  id = "my_db"
}

resource "aws_db_instance" "my_db" {
  instance_class      = "db.t3.micro"
  storage_encrypted   = true
  skip_final_snapshot = true
}