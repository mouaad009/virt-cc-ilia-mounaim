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
