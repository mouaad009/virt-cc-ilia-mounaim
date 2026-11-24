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
