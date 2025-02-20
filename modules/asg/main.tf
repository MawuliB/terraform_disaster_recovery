resource "aws_launch_template" "asg_template" {
  name_prefix   = "web-server-template-"
  description   = "Web Server Launch Template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = filebase64("${path.root}/scripts/user_data.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns = [ var.alb_target_group_arn ]

  health_check_type = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServer-ASG"
    propagate_at_launch = true
  }
}
