
resource "aws_security_group" "ec2-sg" {
    name = "${var.alb_name}-instance"
    description = "allow HTTPS to ${var.alb_name} Load Balancer (ALB)"
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = "443"
        to_port = "443"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.alb_name}"
    }
}


resource "aws_launch_template" "LT" {
  name_prefix   = "appasg"
  image_id      = "ami-0083662ba17882949"
  instance_type = "t2.micro"
  user_data = filebase64("${path.module}/userdata.sh")
  network_interfaces {
    security_groups = [aws_security_group.ec2-sg.id]
    #subnet_id = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]
  }
}

resource "aws_autoscaling_group" "asg" {
  #availability_zones = var.az
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier = [module.vpc.private_subnet_ids[0],module.vpc.private_subnet_ids[1]]

  launch_template {
    id      = aws_launch_template.LT.id
    version = "$Latest"
  }
}