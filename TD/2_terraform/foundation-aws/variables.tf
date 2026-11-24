variable "region" {
  description = "Région qui accueille les ressources du TD."
  type        = string
  default     = "eu-west-3"
}

variable "plan_de_cours" {
  description = "Utiliser des valeurs fictives pour planifier le TD sur un état vide. Désactiver avec un vrai compte AWS."
  type        = bool
  default     = true
}
