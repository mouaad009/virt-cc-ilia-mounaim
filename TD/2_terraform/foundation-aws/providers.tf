terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.74.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Le plan du TD se fait sans compte AWS. En mode connecté, le SDK utilise son profil habituel.
  access_key                  = var.plan_de_cours ? "exemple-td" : null
  secret_key                  = var.plan_de_cours ? "exemple-td" : null
  skip_credentials_validation = var.plan_de_cours
  skip_requesting_account_id  = var.plan_de_cours
  skip_metadata_api_check     = var.plan_de_cours
}
