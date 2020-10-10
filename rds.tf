resource "aws_security_group" "rds-sg" {
    name = "${var.alb_name}-rds-sg"
    description = "allow 3306 from app to rds"
    vpc_id = module.vpc.vpc_id
    tags = {
        Name = "${var.alb_name}"
    }
}

resource "aws_security_group_rule" "rds-in" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds-sg.id
  source_security_group_id = aws_security_group.ec2-sg.id
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [module.vpc.private_subnet_ids[2],module.vpc.private_subnet_ids[3]]

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = var.db-username
  password             = var.db-password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
}
