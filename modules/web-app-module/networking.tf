# DATA SOURCES
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# SECURITY GROUPS
resource "aws_security_group" "instances" {
  name   = "instance-tf-security-group"
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type                     = "ingress"
  security_group_id        = aws_security_group.instances.id
  from_port                = var.server_port
  to_port                  = var.server_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instances.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# LOAD BALANCER
resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "instances" {
  name     = "example-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_target_group_attachment" "web_server_attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = var.server_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern { values = ["*"] }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_security_group" "alb" {
  name   = "alb-security-group"
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}