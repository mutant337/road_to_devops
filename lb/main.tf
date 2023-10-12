terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
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

resource "aws_security_group" "elb_sg" {
  name_prefix = "elb-sg-"
  description = "Security group for ELB"
  vpc_id      = "vpc-02bc8ac492cf733a7"

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
}

resource "aws_lb" "my_elb" {
  name     = "my-elb"
  internal = false

  security_groups = [aws_security_group.elb_sg.id]
  subnets         = ["subnet-0040af26b3787ba27", "subnet-0299fc35e8296ea20"]

  enable_deletion_protection = false
}

resource "aws_instance" "my_instance" {
  ami                    = "ami-0ea7dc624e77a15d5"
  instance_type          = "t3.micro"
  key_name               = "ssh"
  vpc_security_group_ids = [aws_security_group.elb_sg.id]
  subnet_id              = "subnet-0040af26b3787ba27"
  iam_instance_profile   = aws_iam_instance_profile.my_profile.name

  provisioner "local-exec" {
    command = "bash /home/ubuntu/road_to_devops/lb/script.sh"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name_prefix = "tg-"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-02bc8ac492cf733a7"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "my_tg_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance.id
  port             = 80
}

resource "aws_iam_instance_profile" "my_profile" {
  name = "test_profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "my_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "my_attachment" {
  name       = "SM-policy-attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
