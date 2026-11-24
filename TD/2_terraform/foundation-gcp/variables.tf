variable "region" {
  description = "Région qui accueille les ressources du TD."
  type        = string
  default     = "europe-west1"
}

variable "project_id" {
  description = "Identifiant du projet GCP du cours."
  type        = string
  default     = "polytech-dijon"
}

variable "prefix" {
  description = "Préfixe court et unique pour les noms des ressources."
  type        = string
  default     = "td2-mounaim"
}

variable "dns_domain" {
  description = "Nom de la zone DNS privée, avec le point final."
  type        = string
  default     = "td2.internal."
}

variable "zone_suffixes" {
  description = "Suffixes de deux zones distinctes au minimum dans la région choisie."
  type        = set(string)
  default     = ["b", "c"]
  validation {
    condition     = length(var.zone_suffixes) >= 2 && alltrue([for z in var.zone_suffixes : can(regex("^[a-z]$", z))])
    error_message = "Indiquer au moins deux suffixes de zone distincts (par exemple b et c)."
  }
}

variable "access_token" {
  description = "Valeur fictive du cours pour le plan. Utiliser null pour les identifiants Google par défaut."
  type        = string
  sensitive   = true
  default     = "patate"
}
