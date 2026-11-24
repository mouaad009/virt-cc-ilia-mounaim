output "vpc_id" {
  description = "Identifiant du VPC."
  value       = module.foundation.vpc_id
}

output "vm_private_ips" {
  description = "Adresses privées des machines applicatives."
  value       = module.foundation.vm_private_ips
}

output "database_host" {
  description = "Hôte privé de PostgreSQL pour la configuration applicative."
  value       = module.foundation.database_host
}

output "app_dns" {
  description = "Nom DNS privé des machines applicatives."
  value       = module.foundation.app_dns
}
