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

# Machines virtuelles

resource "google_compute_instance" "app" {
  name         = "${var.prefix}-vm-b"
  zone         = "${var.region}-b"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.app.id
  }
}
