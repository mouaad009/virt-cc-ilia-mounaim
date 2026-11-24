variable "region" {
  description = "Région qui accueille les ressources du TD."
  type        = string
}

variable "prefix" {
  description = "Préfixe court et unique pour les noms des ressources."
  type        = string
}

variable "dns_domain" {
  description = "Nom de la zone DNS privée, avec le point final."
  type        = string
}
