output "vpc_id" {
  description = "Identifiant du VPC."
  value       = google_compute_network.main.id
}
