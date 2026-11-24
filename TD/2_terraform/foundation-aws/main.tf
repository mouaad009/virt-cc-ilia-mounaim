# Réseau privé

resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.prefix}-vpc" }
}

locals {
  subnet_cidrs = { a = "10.20.1.0/24", b = "10.20.2.0/24" }
}
resource "aws_subnet" "app" {
  for_each          = local.subnet_cidrs
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}${each.key}"
  cidr_block        = each.value
  tags              = { Name = "${var.prefix}-${each.key}" }
}

# Machines virtuelles

resource "aws_security_group" "app" {
  name        = "${var.prefix}-app"
  description = "Application instances"
  vpc_id      = aws_vpc.main.id
}
resource "aws_instance" "app" {
  ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.app["a"].id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = false
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  tags = { Name = "${var.prefix}-vm-a" }
}

# PostgreSQL

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.prefix}-pg"
  subnet_ids = [for subnet in aws_subnet.app : subnet.id]
}
resource "aws_security_group" "postgres" {
  name        = "${var.prefix}-pg"
  description = "PostgreSQL from application instances"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "postgres_from_app" {
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
resource "aws_vpc_security_group_egress_rule" "app_to_postgres" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.postgres.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
resource "aws_db_instance" "postgres" {
  identifier                  = "${var.prefix}-pg"
  engine                      = "postgres"
  engine_version              = "16"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = "application"
  username                    = "appadmin"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.postgres.name
  vpc_security_group_ids      = [aws_security_group.postgres.id]
  publicly_accessible         = false
  skip_final_snapshot         = true
}
