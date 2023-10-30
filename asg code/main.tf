provider "aws" {
  region = var.region
}

data "aws_security_group" "default" {
  name = "default"
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

resource "aws_launch_template" "my_launch_template" {
  name                   = "my_launch_template"
  image_id               = "ami-0550c2ee59485be53"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.default.id]
}

resource "aws_autoscaling_group" "autoscale" {
  name                 = "test_autoscaling_group"
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [data.aws_subnet.a.id, data.aws_subnet.b.id]

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_schedule" "add" {
  scheduled_action_name  = "add"
  desired_capacity       = 3
  max_size               = 3
  min_size               = 1
  start_time             = "2023-10-30T18:10:00Z"
  end_time               = "2024-10-30T17:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.autoscale.name
  recurrence             = "5 * * * *"
}

resource "aws_autoscaling_schedule" "terminate" {
  scheduled_action_name  = "terminate"
  desired_capacity       = 1
  max_size               = 3
  min_size               = 1
  start_time             = "2023-10-30T18:15:00Z"
  end_time               = "2024-10-30T17:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.autoscale.name
  recurrence             = "5 * * * *"
}