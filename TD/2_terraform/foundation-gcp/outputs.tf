output "vpc_id" {
  description = "Identifiant du VPC."
  value       = google_compute_network.main.id
}

output "vm_private_ips" {
  description = "Adresses privées des machines applicatives."
  value       = [google_compute_instance.app.network_interface[0].network_ip]
}
