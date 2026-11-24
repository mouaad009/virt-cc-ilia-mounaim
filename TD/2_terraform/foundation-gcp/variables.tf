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

variable "access_token" {
  description = "Valeur fictive du cours pour le plan. Utiliser null pour les identifiants Google par défaut."
  type        = string
  sensitive   = true
  default     = "patate"
}
