module "foundation" {
  source = "../modules/gcp"

  prefix        = var.prefix
  region        = var.region
  dns_domain    = var.dns_domain
  zone_suffixes = var.zone_suffixes
}

# Conserver les adresses de l’état après extraction du module.

moved {
  from = google_compute_network.main
  to   = module.foundation.google_compute_network.main
}

moved {
  from = google_compute_subnetwork.app
  to   = module.foundation.google_compute_subnetwork.app
}

moved {
  from = google_compute_instance.app
  to   = module.foundation.google_compute_instance.app
}

moved {
  from = google_compute_global_address.services
  to   = module.foundation.google_compute_global_address.services
}

moved {
  from = google_service_networking_connection.services
  to   = module.foundation.google_service_networking_connection.services
}

moved {
  from = google_sql_database_instance.postgres
  to   = module.foundation.google_sql_database_instance.postgres
}

moved {
  from = google_dns_managed_zone.app
  to   = module.foundation.google_dns_managed_zone.app
}

moved {
  from = google_dns_record_set.app
  to   = module.foundation.google_dns_record_set.app
}
