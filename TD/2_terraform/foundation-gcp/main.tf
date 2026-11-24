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

# PostgreSQL

resource "google_compute_global_address" "services" {
  name          = "${var.prefix}-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}
resource "google_service_networking_connection" "services" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.services.name]
}
resource "google_sql_database_instance" "postgres" {
  name             = "${var.prefix}-pg"
  region           = var.region
  database_version = "POSTGRES_16"
  depends_on       = [google_service_networking_connection.services]
  settings {
    edition = "ENTERPRISE"
    tier    = "db-custom-1-3840"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.self_link
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
}

# DNS privé

resource "google_dns_managed_zone" "app" {
  name       = "${var.prefix}-dns"
  dns_name   = var.dns_domain
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.main.id
    }
  }
}
resource "google_dns_record_set" "app" {
  name         = "app.${google_dns_managed_zone.app.dns_name}"
  managed_zone = google_dns_managed_zone.app.name
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_instance.app.network_interface[0].network_ip]
}
