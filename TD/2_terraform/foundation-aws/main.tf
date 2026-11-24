module "foundation" {
  source = "../modules/aws"

  prefix     = var.prefix
  region     = var.region
  dns_domain = var.dns_domain
}

# Conserver les adresses de l’état après extraction du module.

moved {
  from = aws_vpc.main
  to   = module.foundation.aws_vpc.main
}

moved {
  from = aws_subnet.app
  to   = module.foundation.aws_subnet.app
}

moved {
  from = aws_security_group.app
  to   = module.foundation.aws_security_group.app
}

moved {
  from = aws_instance.app
  to   = module.foundation.aws_instance.app
}

moved {
  from = aws_db_subnet_group.postgres
  to   = module.foundation.aws_db_subnet_group.postgres
}

moved {
  from = aws_security_group.postgres
  to   = module.foundation.aws_security_group.postgres
}

moved {
  from = aws_vpc_security_group_ingress_rule.postgres_from_app
  to   = module.foundation.aws_vpc_security_group_ingress_rule.postgres_from_app
}

moved {
  from = aws_vpc_security_group_egress_rule.app_to_postgres
  to   = module.foundation.aws_vpc_security_group_egress_rule.app_to_postgres
}

moved {
  from = aws_db_instance.postgres
  to   = module.foundation.aws_db_instance.postgres
}

moved {
  from = aws_route53_zone.app
  to   = module.foundation.aws_route53_zone.app
}

moved {
  from = aws_route53_record.app
  to   = module.foundation.aws_route53_record.app
}
