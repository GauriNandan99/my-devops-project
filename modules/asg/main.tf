#launch template for autoscaling
resource "aws_launch_template" "base" {
  name          = var.template_details.name
  image_id      = var.ami_info.id
  instance_type = var.template_details.instance_type
  key_name      = var.template_details.key_name
  user_data     = filebase64(var.template_details.script_path)
  network_interfaces {
    associate_public_ip_address = var.template_details.associate_public_ip_address
    device_index                = "0"
    security_groups             = var.template_details.security_group_ids
  }

}

#autoscaling limits
resource "aws_autoscaling_group" "base" {
  name                = "${var.template_details.name}-asg"
  min_size            = var.scaling_details.min_size
  max_size            = var.scaling_details.max_size
  vpc_zone_identifier = var.scaling_details.subnet_ids
  launch_template {
    id      = aws_launch_template.base.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.base.arn]

}

#loadBalancer creation
resource "aws_lb" "base" {
  name               = "${var.template_details.name}-lb"
  internal           = var.lb_details.internal
  load_balancer_type = var.lb_details.type
  security_groups    = var.lb_details.security_group_ids
  subnets            = var.lb_details.subnet_ids
}

resource "aws_lb_target_group" "base" {
  name     = "${var.template_details.name}-tg"
  port     = var.lb_details.application_port
  protocol = "HTTP"
  vpc_id   = var.lb_details.vpc_id

  health_check {
    path                = "/"
    interval            = 6
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "base" {
  load_balancer_arn = aws_lb.base.arn
  port              = var.lb_details.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.base.arn
  }
}
