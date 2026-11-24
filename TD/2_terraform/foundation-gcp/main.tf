# Réseau privé

resource "google_compute_network" "main" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "app" {
  name          = "${var.prefix}-app"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = "10.10.1.0/24"
}
