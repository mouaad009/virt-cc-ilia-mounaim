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

variable "zone_suffixes" {
  description = "Suffixes de deux zones distinctes au minimum dans la région choisie."
  type        = set(string)
  validation {
    condition     = length(var.zone_suffixes) >= 2 && alltrue([for z in var.zone_suffixes : can(regex("^[a-z]$", z))])
    error_message = "Indiquer au moins deux suffixes de zone distincts (par exemple b et c)."
  }
}
