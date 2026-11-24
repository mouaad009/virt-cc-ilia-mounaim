output "vpc_id" {
  description = "Identifiant du VPC."
  value       = aws_vpc.main.id
}

output "vm_private_ips" {
  description = "Adresses privées des machines applicatives."
  value       = [aws_instance.app.private_ip]
}

output "database_host" {
  description = "Hôte privé de PostgreSQL pour la configuration applicative."
  value       = aws_db_instance.postgres.address
}
