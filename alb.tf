resource "aws_security_group" "demo-alb" {
  name        = "${var.alb_name}-load-balancer"
  description = "allow HTTPS to ${var.alb_name} Load Balancer (ALB)"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.alb_name}"
  }
}

resource "aws_security_group_rule" "alb-ec2" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo-alb.id
  source_security_group_id = aws_security_group.ec2-sg.id
}


# Create a single load balancer for all demo services
resource "aws_alb" "demo" {
  name                       = "${var.alb_name}"
  internal                   = false
  idle_timeout               = "300"
  security_groups            = [aws_security_group.demo-alb.id]
  subnets                    = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  enable_deletion_protection = true

  # access_logs {
  #   bucket = "${aws_s3_bucket.alb_logs.bucket}"
  #   prefix = "test-alb"
  # }

  tags = {
    Name = var.alb_name
  }
}

# Define a listener
resource "aws_alb_listener" "demo" {
  load_balancer_arn = "${aws_alb.demo.arn}"
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2015-05"
  #certificate_arn   = "${var.ssl_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}


# Connect app ASG up to the Application Load Balancer (see load-balancer.tf)
resource "aws_alb_target_group" "app" {
  name     = "${var.alb_name}-app"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
  health_check {
    path = "/"
    matcher = "200-399"
  }

}

resource "aws_alb_listener_rule" "app" {
  listener_arn = "${aws_alb_listener.demo.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.app.arn}"
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}