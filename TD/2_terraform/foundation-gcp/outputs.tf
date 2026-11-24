output "vpc_id" {
  description = "Identifiant du VPC."
  value       = google_compute_network.main.id
}

output "vm_private_ips" {
  description = "Adresses privées des machines applicatives."
  value       = [for vm in google_compute_instance.app : vm.network_interface[0].network_ip]
}

output "database_host" {
  description = "Hôte privé de PostgreSQL pour la configuration applicative."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "app_dns" {
  description = "Nom DNS privé des machines applicatives."
  value       = google_dns_record_set.app.name
}
