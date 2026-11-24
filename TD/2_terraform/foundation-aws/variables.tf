variable "region" {
  description = "Région qui accueille les ressources du TD."
  type        = string
  default     = "eu-west-3"
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

variable "plan_de_cours" {
  description = "Utiliser des valeurs fictives pour planifier le TD sur un état vide. Désactiver avec un vrai compte AWS."
  type        = bool
  default     = true
}
