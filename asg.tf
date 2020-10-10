
resource "aws_security_group" "ec2-sg" {
    name = "${var.alb_name}-instance"
    description = "allow HTTPS to ${var.alb_name} Load Balancer (ALB)"
    vpc_id = module.vpc.vpc_id
    tags = {
        Name = "${var.alb_name}"
    }
}

resource "aws_security_group_rule" "ec2-alb-in" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.demo-alb.id
  security_group_id = aws_security_group.ec2-sg.id
}

resource "aws_security_group_rule" "ec2-rds-out" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.rds-sg.id
  security_group_id = aws_security_group.ec2-sg.id
}

resource "aws_launch_template" "LT" {
  name_prefix   = "appasg"
  image_id      = "ami-0083662ba17882949"
  instance_type = "t2.small"
  user_data = filebase64("${path.module}/userdata.sh")
  network_interfaces {
    security_groups = [aws_security_group.ec2-sg.id]
    #subnet_id = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]
  }
}

# resource "aws_autoscaling_group" "asg" {
#   #availability_zones = var.az
#   desired_capacity   = 2
#   max_size           = 4
#   min_size           = 2
#   vpc_zone_identifier = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]

#   launch_template {
#     id      = aws_launch_template.LT.id
#     version = "$Latest"
#   }
# }