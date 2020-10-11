provider "aws" {
  #access_key = var.access_key
  #secret_key = var.secret_key
  region = var.region
}


module "vpc" {
  source              = "github.com/yunoth/alb-demo.git//modules/vpc?ref=master"
  cidr_block          = "10.1.0.0/16"
  public_subnet_cidr  = ["10.1.100.0/24", "10.1.200.0/24"]
  private_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  az                  = var.az
  subnet_tags = {
    Name = "subnet"
  }
  vpc_tags = {
    Name = "demovpc"
  }
}

# resource "aws_route53_zone" "private" {
#   name = "demo.net"
#   vpc {
#     vpc_id = module.vpc.vpc_id
#   }
# }

# resource "aws_route53_record" "rds" {
#   zone_id = aws_route53_zone.private.zone_id
#   name    = "db.demo.net"
#   type    = "cname"
#   ttl     = "300"
#   records = [aws_db_instance.rds.address]
# }

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "pemkey"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  content         = tls_private_key.example.private_key_pem
  filename        = "/tmp/demo.pem"
  file_permission = "0400"
}


# data "template_file" "user_data" {
#   count    = 1
#   template = "${file("${path.module}/userdata.tpl")}"
# }

# module "instance1" {
#   source                      = "./modules/ec2"
#   ami                         = "ami-0083662ba17882949"
#   instance_type               = "t3.small"
#   key_name                    = "${aws_key_pair.generated_key.key_name}"
#   vpc_security_group_ids      = [aws_security_group.sg.id]
#   subnet_id                   = module.vpc.private_subnet_ids[0]
#   associate_public_ip_address = true
#   user_data                   = data.template_file.user_data.0.rendered
#   tags = {
#     env     = "demo"
#     service = "apache"
#     Name    = "app1"
#   }
# }

# module "instance2" {
#   source                      = "./modules/ec2"
#   ami                         = "ami-0083662ba17882949"
#   instance_type               = "t3.small"
#   key_name                    = "${aws_key_pair.generated_key.key_name}"
#   vpc_security_group_ids      = [aws_security_group.sg.id]
#   subnet_id                   = module.vpc.private_subnet_ids[1]
#   associate_public_ip_address = true
#   user_data                   = data.template_file.user_data.0.rendered
#   tags = {
#     env     = "demo"
#     service = "apache"
#     Name    = "app2"
#   }
# }
