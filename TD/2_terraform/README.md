# TD 2 · Provisionner une infrastructure avec Terraform

**MOUNAIM Mouaad · ILIA · Polytech Dijon**

L’exercice construit le même réseau applicatif sur Google Cloud et AWS. Dans chaque VPC, le nom privé `app.td2.internal.` renvoie les deux adresses privées des VM. L’application peut joindre PostgreSQL par son hôte privé, disponible dans la sortie `database_host`.

| Composant | [Google Cloud](foundation-gcp) | [AWS](foundation-aws) |
| --- | --- | --- |
| Région | `europe-west1` (Belgique) | `eu-west-3` (Paris) |
| Réseau | VPC et sous-réseau régional | VPC et deux sous-réseaux privés |
| Calcul | Deux VM Compute Engine, zones `b` et `c` | Deux instances EC2, zones `a` et `b` |
| Base de données | Cloud SQL PostgreSQL 16, IP privée via Private Services Access | RDS PostgreSQL 16, port 5432 autorisé entre les groupes de sécurité des VM et de la base |
| DNS | Zone Cloud DNS privée liée au VPC | Zone Route 53 privée associée au VPC |

Le méta-argument `for_each` crée une VM par zone. Le DNS publie leurs deux adresses avec un TTL de 60 secondes. Cette étape apporte de la redondance côté calcul. La surveillance de santé DNS et la bascule automatique de la base restent hors du périmètre de l’exercice.

## Organisation des fichiers

Les répertoires [foundation-gcp](foundation-gcp) et [foundation-aws](foundation-aws) sont les deux points d’entrée. Chacun appelle son module local dans [modules/gcp](modules/gcp) ou [modules/aws](modules/aws). Les quatre fichiers du tableau se retrouvent dans chaque répertoire Terraform.

| Fichier | Rôle |
| --- | --- |
| `main.tf` | Déclare les ressources dans le module, et appelle ce module depuis la configuration principale. |
| `variables.tf` | Déclare les paramètres, leur type et, dans la configuration principale, les valeurs du TD. |
| `outputs.tf` | Expose le VPC, les IP privées des VM, l’hôte PostgreSQL et le nom DNS. |
| `providers.tf` | Déclare le provider requis. La configuration principale fixe sa version et ses paramètres. |

Le provider Google reprend l’exemple du tableau. Le projet est `polytech-dijon`, la région est `europe-west1` et le jeton fictif du plan est `patate`. Le [.gitignore](../../.gitignore) contient la règle `**/.terraform*` demandée. Elle exclut le répertoire local Terraform et le fichier de verrouillage. Les versions des providers sont donc fixées dans les deux fichiers `providers.tf` principaux.

## Exécuter le TD

Depuis la racine du dépôt, avec Terraform installé, lancer les commandes suivantes dans PowerShell ou dans un terminal Linux.

```sh
terraform -chdir=TD/2_terraform/foundation-gcp init
terraform -chdir=TD/2_terraform/foundation-gcp validate
terraform -chdir=TD/2_terraform/foundation-gcp plan

terraform -chdir=TD/2_terraform/foundation-aws init
terraform -chdir=TD/2_terraform/foundation-aws validate
terraform -chdir=TD/2_terraform/foundation-aws plan
```

`init` installe le provider et charge le module. `validate` vérifie la configuration. `plan` affiche les créations proposées. Il faut un accès au registre lors de la première installation. Avec un état vide, les valeurs par défaut suffisent pour les plans du TD.

Pour un plan connecté à un vrai compte, utiliser un fichier `terraform.tfvars` local dans le répertoire du fournisseur. Sur GCP, indiquer `access_token = null` pour utiliser les identifiants Google par défaut et, si nécessaire, changer `project_id`. Sur AWS, indiquer `plan_de_cours = false` et utiliser le profil AWS ou les identifiants temporaires du compte. Ces fichiers locaux sont ignorés par Git.

## Résultats par étape

Chaque ligne correspond à un commit par fournisseur. `terraform validate` et `terraform plan` ont réussi sur les 14 configurations. Chaque plan part d’un état vide. Chaque chiffre indique le nombre total de ressources à créer et ouvre le commit correspondant. Tous les plans comportent zéro modification et zéro destruction.

| Étape | Travail réalisé | Créations GCP | Créations AWS |
| --- | --- | ---: | ---: |
| 0 | Déclarer le provider et la région | [0](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/e0e9870f78328d81109016be8f49a489d1ee827e) | [0](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/e287ea8b828031cfd32282b2109abac4bf530d49) |
| 1 | Créer le VPC et les sous-réseaux | [2](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/931e5c6cbf2fcff1a3f26eee7f6fcf5df4492aaf) | [3](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/60bbed6998818a4a33e600df0ee35ec8d1145cde) |
| 2 | Ajouter la première VM privée | [3](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/affc3640a15d436bd968018a38778df66ce3731f) | [5](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/840573179966b9f35def2f9bdf354a4551074822) |
| 3 | Raccorder PostgreSQL au réseau privé | [6](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/77eb2036b8d6e0d1a4ca0557c3a8cdca61f8fc78) | [10](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/125aa89ff236fb135e4b8a67b85d2de7d788e827) |
| 4 | Créer la zone et l’enregistrement DNS | [8](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/44ee04fdcd36507dba700e7bdda1e1b2a8864465) | [12](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/ed3dcfd83d4265f1fbfecfa1403a9aa722dd5cce) |
| 5 | Répartir les VM entre deux zones | [9](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/050b860f334d2bb9a2a1a77d514fd193ede4d9fa) | [13](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/d3b40232a70f0fe2aee14eb8453aec6699eadbd1) |
| Module | Extraire un module réutilisable par fournisseur | [9](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/557ffe14e661bc5a52b8f66820e7bd514762cf1d) | [13](https://github.com/mouaad009/TD_virtualisation_cloud_MOUNAIM_Mouaad/commit/bac8c0acde834c9edf47accbc80e575a19e86eed) |

Les vérifications ont utilisé Terraform 1.17.2 et les binaires officiels des providers Google 8.12.0 et AWS 6.74.0. Les étapes intermédiaires ont réutilisé une installation locale de ces binaires. Les deux plans finaux ci-dessous ont utilisé la sélection standard des providers. Les valeurs d’authentification du TD sont fictives. Les plans ne vérifient ni les droits du compte de l’école ni ses quotas. Aucune ressource cloud n’a été déployée.

## Sorties complètes de terraform plan

<details>
<summary>Google Cloud · 9 ressources à créer</summary>

```text
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.foundation.google_compute_global_address.services will be created
  + resource "google_compute_global_address" "services" {
      + address            = (known after apply)
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + deletion_policy    = "DELETE"
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "td2-mounaim-services"
      + network            = (known after apply)
      + prefix_length      = 16
      + project            = "polytech-dijon"
      + purpose            = "VPC_PEERING"
      + self_link          = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
    }

  # module.foundation.google_compute_instance.app["b"] will be created
  + resource "google_compute_instance" "app" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_policy      = "DELETE"
      + deletion_protection  = false
      + effective_labels     = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "e2-micro"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "td2-mounaim-vm-b"
      + project              = "polytech-dijon"
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "goog-terraform-provisioned" = "true"
        }
      + zone                 = "europe-west1-b"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + guest_os_features          = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + architecture           = (known after apply)
              + image                  = "debian-cloud/debian-12"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = (known after apply)
              + snapshot               = (known after apply)
              + type                   = (known after apply)
            }
        }

      + confidential_instance_config (known after apply)

      + guest_accelerator (known after apply)

      + network_interface {
          + igmp_query                  = (known after apply)
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_attachment          = (known after apply)
          + network_ip                  = (known after apply)
          + parent_nic_name             = (known after apply)
          + stack_type                  = (known after apply)
          + subnetwork                  = (known after apply)
          + subnetwork_project          = (known after apply)
        }

      + reservation_affinity (known after apply)

      + scheduling (known after apply)
    }

  # module.foundation.google_compute_instance.app["c"] will be created
  + resource "google_compute_instance" "app" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_policy      = "DELETE"
      + deletion_protection  = false
      + effective_labels     = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "e2-micro"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "td2-mounaim-vm-c"
      + project              = "polytech-dijon"
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "goog-terraform-provisioned" = "true"
        }
      + zone                 = "europe-west1-c"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + guest_os_features          = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + architecture           = (known after apply)
              + image                  = "debian-cloud/debian-12"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = (known after apply)
              + snapshot               = (known after apply)
              + type                   = (known after apply)
            }
        }

      + confidential_instance_config (known after apply)

      + guest_accelerator (known after apply)

      + network_interface {
          + igmp_query                  = (known after apply)
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_attachment          = (known after apply)
          + network_ip                  = (known after apply)
          + parent_nic_name             = (known after apply)
          + stack_type                  = (known after apply)
          + subnetwork                  = (known after apply)
          + subnetwork_project          = (known after apply)
        }

      + reservation_affinity (known after apply)

      + scheduling (known after apply)
    }

  # module.foundation.google_compute_network.main will be created
  + resource "google_compute_network" "main" {
      + auto_create_subnetworks                   = false
      + bgp_always_compare_med                    = (known after apply)
      + bgp_best_path_selection_mode              = (known after apply)
      + bgp_inter_region_cost                     = (known after apply)
      + delete_bgp_always_compare_med             = false
      + delete_default_routes_on_create           = false
      + deletion_policy                           = "DELETE"
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = (known after apply)
      + name                                      = "td2-mounaim-vpc"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "polytech-dijon"
      + routing_mode                              = (known after apply)
      + self_link                                 = (known after apply)
    }

  # module.foundation.google_compute_subnetwork.app will be created
  + resource "google_compute_subnetwork" "app" {
      + allow_subnet_cidr_routes_overlap = (known after apply)
      + creation_timestamp               = (known after apply)
      + deletion_policy                  = "DELETE"
      + external_ipv6_prefix             = (known after apply)
      + fingerprint                      = (known after apply)
      + gateway_address                  = (known after apply)
      + id                               = (known after apply)
      + internal_ipv6_prefix             = (known after apply)
      + ip_cidr_range                    = "10.10.1.0/24"
      + ipv6_cidr_range                  = (known after apply)
      + ipv6_gce_endpoint                = (known after apply)
      + name                             = "td2-mounaim-app"
      + network                          = (known after apply)
      + private_ip_google_access         = (known after apply)
      + private_ipv6_google_access       = (known after apply)
      + project                          = "polytech-dijon"
      + purpose                          = (known after apply)
      + region                           = "europe-west1"
      + self_link                        = (known after apply)
      + stack_type                       = (known after apply)
      + state                            = (known after apply)
      + subnetwork_id                    = (known after apply)

      + secondary_ip_range (known after apply)
    }

  # module.foundation.google_dns_managed_zone.app will be created
  + resource "google_dns_managed_zone" "app" {
      + creation_time    = (known after apply)
      + deletion_policy  = "DELETE"
      + description      = "Managed by Terraform"
      + dns_name         = "td2.internal."
      + effective_labels = {
          + "goog-terraform-provisioned" = "true"
        }
      + force_destroy    = false
      + id               = (known after apply)
      + managed_zone_id  = (known after apply)
      + name             = "td2-mounaim-dns"
      + name_servers     = (known after apply)
      + project          = "polytech-dijon"
      + terraform_labels = {
          + "goog-terraform-provisioned" = "true"
        }
      + visibility       = "private"

      + cloud_logging_config (known after apply)

      + dnssec_config (known after apply)

      + private_visibility_config {
          + networks {
              + network_url = (known after apply)
            }
        }
    }

  # module.foundation.google_dns_record_set.app will be created
  + resource "google_dns_record_set" "app" {
      + deletion_policy = "DELETE"
      + id              = (known after apply)
      + managed_zone    = "td2-mounaim-dns"
      + name            = "app.td2.internal."
      + project         = "polytech-dijon"
      + rrdatas         = (known after apply)
      + ttl             = 60
      + type            = "A"
    }

  # module.foundation.google_service_networking_connection.services will be created
  + resource "google_service_networking_connection" "services" {
      + deletion_policy         = "DELETE"
      + id                      = (known after apply)
      + network                 = (known after apply)
      + peering                 = (known after apply)
      + reserved_peering_ranges = [
          + "td2-mounaim-services",
        ]
      + service                 = "servicenetworking.googleapis.com"
    }

  # module.foundation.google_sql_database_instance.postgres will be created
  + resource "google_sql_database_instance" "postgres" {
      + available_maintenance_versions       = (known after apply)
      + connection_name                      = (known after apply)
      + database_version                     = "POSTGRES_16"
      + deletion_policy                      = "DELETE"
      + deletion_protection                  = true
      + dns_name                             = (known after apply)
      + dns_names                            = (known after apply)
      + encryption_confidential_mode         = (known after apply)
      + encryption_key_name                  = (known after apply)
      + enforce_new_sql_network_architecture = (known after apply)
      + first_ip_address                     = (known after apply)
      + id                                   = (known after apply)
      + instance_type                        = (known after apply)
      + ip_address                           = (known after apply)
      + maintenance_version                  = (known after apply)
      + master_instance_name                 = (known after apply)
      + name                                 = "td2-mounaim-pg"
      + node_count                           = (known after apply)
      + private_ip_address                   = (known after apply)
      + project                              = "polytech-dijon"
      + psc_service_attachment_link          = (known after apply)
      + public_ip_address                    = (known after apply)
      + region                               = "europe-west1"
      + replica_names                        = (known after apply)
      + root_password_wo                     = (write-only attribute)
      + self_link                            = (known after apply)
      + server_ca_cert                       = (sensitive value)
      + service_account_email_address        = (known after apply)

      + replica_configuration (known after apply)

      + replication_cluster (known after apply)

      + settings {
          + activation_policy                = "ALWAYS"
          + availability_type                = "ZONAL"
          + connector_enforcement            = (known after apply)
          + data_api_access                  = (known after apply)
          + data_disk_provisioned_iops       = (known after apply)
          + data_disk_provisioned_throughput = (known after apply)
          + disk_autoresize                  = true
          + disk_autoresize_limit            = 0
          + disk_size                        = (known after apply)
          + disk_type                        = (known after apply)
          + edition                          = "ENTERPRISE"
          + effective_availability_type      = (known after apply)
          + pricing_plan                     = "PER_USE"
          + replication_lag_max_seconds      = (known after apply)
          + tier                             = "db-custom-1-3840"
          + user_labels                      = (known after apply)
          + version                          = (known after apply)

          + backup_configuration (known after apply)

          + connection_pool_config (known after apply)

          + data_cache_config (known after apply)

          + insights_config (known after apply)

          + ip_configuration {
              + ipv4_enabled    = false
              + private_network = (known after apply)
              + server_ca_mode  = (known after apply)
              + ssl_mode        = "ENCRYPTED_ONLY"
            }

          + location_preference (known after apply)

          + read_pool_auto_scale_config (known after apply)
        }
    }

Plan: 9 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + app_dns        = "app.td2.internal."
  + database_host  = (known after apply)
  + vm_private_ips = [
      + (known after apply),
      + (known after apply),
    ]
  + vpc_id         = (known after apply)
```

</details>

<details>
<summary>AWS · 13 ressources à créer</summary>

```text
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.foundation.aws_db_instance.postgres will be created
  + resource "aws_db_instance" "postgres" {
      + address                               = (known after apply)
      + allocated_storage                     = 20
      + apply_immediately                     = false
      + arn                                   = (known after apply)
      + auto_minor_version_upgrade            = true
      + availability_zone                     = (known after apply)
      + backup_retention_period               = (known after apply)
      + backup_target                         = (known after apply)
      + backup_window                         = (known after apply)
      + ca_cert_identifier                    = (known after apply)
      + character_set_name                    = (known after apply)
      + copy_tags_to_snapshot                 = false
      + database_insights_mode                = (known after apply)
      + db_name                               = "application"
      + db_subnet_group_name                  = "td2-mounaim-pg"
      + dedicated_log_volume                  = false
      + delete_automated_backups              = true
      + domain_fqdn                           = (known after apply)
      + endpoint                              = (known after apply)
      + engine                                = "postgres"
      + engine_lifecycle_support              = (known after apply)
      + engine_version                        = "16"
      + engine_version_actual                 = (known after apply)
      + hosted_zone_id                        = (known after apply)
      + id                                    = (known after apply)
      + identifier                            = "td2-mounaim-pg"
      + identifier_prefix                     = (known after apply)
      + instance_class                        = "db.t4g.micro"
      + iops                                  = (known after apply)
      + kms_key_id                            = (known after apply)
      + latest_restorable_time                = (known after apply)
      + license_model                         = (known after apply)
      + listener_endpoint                     = (known after apply)
      + maintenance_window                    = (known after apply)
      + manage_master_user_password           = true
      + master_user_secret                    = (known after apply)
      + master_user_secret_kms_key_id         = (known after apply)
      + monitoring_interval                   = 0
      + monitoring_role_arn                   = (known after apply)
      + multi_az                              = (known after apply)
      + multi_tenant                          = (known after apply)
      + nchar_character_set_name              = (known after apply)
      + network_type                          = (known after apply)
      + option_group_name                     = (known after apply)
      + parameter_group_name                  = (known after apply)
      + password_wo                           = (write-only attribute)
      + performance_insights_enabled          = false
      + performance_insights_kms_key_id       = (known after apply)
      + performance_insights_retention_period = (known after apply)
      + port                                  = (known after apply)
      + publicly_accessible                   = false
      + region                                = "eu-west-3"
      + replica_mode                          = (known after apply)
      + replicas                              = (known after apply)
      + resource_id                           = (known after apply)
      + skip_final_snapshot                   = true
      + snapshot_identifier                   = (known after apply)
      + status                                = (known after apply)
      + storage_encrypted                     = true
      + storage_throughput                    = (known after apply)
      + storage_type                          = "gp3"
      + tags_all                              = (known after apply)
      + timezone                              = (known after apply)
      + upgrade_rollout_order                 = (known after apply)
      + username                              = "appadmin"
      + vpc_security_group_ids                = (known after apply)
    }

  # module.foundation.aws_db_subnet_group.postgres will be created
  + resource "aws_db_subnet_group" "postgres" {
      + arn                     = (known after apply)
      + description             = "Managed by Terraform"
      + id                      = (known after apply)
      + name                    = "td2-mounaim-pg"
      + name_prefix             = (known after apply)
      + region                  = "eu-west-3"
      + subnet_ids              = (known after apply)
      + supported_network_types = (known after apply)
      + tags_all                = (known after apply)
      + vpc_id                  = (known after apply)
    }

  # module.foundation.aws_instance.app["a"] will be created
  + resource "aws_instance" "app" {
      + ami                                  = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = false
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "eu-west-3"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "td2-mounaim-vm-a"
        }
      + tags_all                             = {
          + "Name" = "td2-mounaim-vm-a"
        }
      + tenancy                              = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options {
          + http_endpoint               = "enabled"
          + http_protocol_ipv6          = "disabled"
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = "required"
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = true
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags_all              = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + secondary_network_interface (known after apply)
    }

  # module.foundation.aws_instance.app["b"] will be created
  + resource "aws_instance" "app" {
      + ami                                  = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = false
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "eu-west-3"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "td2-mounaim-vm-b"
        }
      + tags_all                             = {
          + "Name" = "td2-mounaim-vm-b"
        }
      + tenancy                              = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options {
          + http_endpoint               = "enabled"
          + http_protocol_ipv6          = "disabled"
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = "required"
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = true
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags_all              = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + secondary_network_interface (known after apply)
    }

  # module.foundation.aws_route53_record.app will be created
  + resource "aws_route53_record" "app" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "app.td2.internal"
      + records         = (known after apply)
      + ttl             = 60
      + type            = "A"
      + zone_id         = (known after apply)
    }

  # module.foundation.aws_route53_zone.app will be created
  + resource "aws_route53_zone" "app" {
      + arn                         = (known after apply)
      + comment                     = "Managed by Terraform"
      + enable_accelerated_recovery = (known after apply)
      + force_destroy               = false
      + id                          = (known after apply)
      + name                        = "td2.internal"
      + name_servers                = (known after apply)
      + primary_name_server         = (known after apply)
      + tags                        = {
          + "Name" = "td2-mounaim-dns"
        }
      + tags_all                    = {
          + "Name" = "td2-mounaim-dns"
        }
      + zone_id                     = (known after apply)

      + vpc {
          + vpc_id     = (known after apply)
          + vpc_region = (known after apply)
        }
    }

  # module.foundation.aws_security_group.app will be created
  + resource "aws_security_group" "app" {
      + arn                    = (known after apply)
      + description            = "Application instances"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "td2-mounaim-app"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "eu-west-3"
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.foundation.aws_security_group.postgres will be created
  + resource "aws_security_group" "postgres" {
      + arn                    = (known after apply)
      + description            = "PostgreSQL from application instances"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "td2-mounaim-pg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "eu-west-3"
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.foundation.aws_subnet.app["a"] will be created
  + resource "aws_subnet" "app" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-3a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + network_firewall_connectivity_type             = (known after apply)
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "eu-west-3"
      + tags                                           = {
          + "Name" = "td2-mounaim-a"
        }
      + tags_all                                       = {
          + "Name" = "td2-mounaim-a"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.foundation.aws_subnet.app["b"] will be created
  + resource "aws_subnet" "app" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-west-3b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.20.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + network_firewall_connectivity_type             = (known after apply)
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "eu-west-3"
      + tags                                           = {
          + "Name" = "td2-mounaim-b"
        }
      + tags_all                                       = {
          + "Name" = "td2-mounaim-b"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.foundation.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.20.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + network_firewall_association         = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "eu-west-3"
      + tags                                 = {
          + "Name" = "td2-mounaim-vpc"
        }
      + tags_all                             = {
          + "Name" = "td2-mounaim-vpc"
        }
    }

  # module.foundation.aws_vpc_security_group_egress_rule.app_to_postgres will be created
  + resource "aws_vpc_security_group_egress_rule" "app_to_postgres" {
      + arn                          = (known after apply)
      + from_port                    = 5432
      + id                           = (known after apply)
      + ip_protocol                  = "tcp"
      + referenced_security_group_id = (known after apply)
      + region                       = "eu-west-3"
      + security_group_id            = (known after apply)
      + security_group_rule_id       = (known after apply)
      + tags_all                     = {}
      + to_port                      = 5432
    }

  # module.foundation.aws_vpc_security_group_ingress_rule.postgres_from_app will be created
  + resource "aws_vpc_security_group_ingress_rule" "postgres_from_app" {
      + arn                          = (known after apply)
      + from_port                    = 5432
      + id                           = (known after apply)
      + ip_protocol                  = "tcp"
      + referenced_security_group_id = (known after apply)
      + region                       = "eu-west-3"
      + security_group_id            = (known after apply)
      + security_group_rule_id       = (known after apply)
      + tags_all                     = {}
      + to_port                      = 5432
    }

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + app_dns        = (known after apply)
  + database_host  = (known after apply)
  + vm_private_ips = [
      + (known after apply),
      + (known after apply),
    ]
  + vpc_id         = (known after apply)
```

</details>

## Documentation consultée

- [Énoncé du TD](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/tds/2_terraform.md) et [rappel Terraform de l’enseignant](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/docs/rappel-terraform.md).
- [Documentation Terraform](https://developer.hashicorp.com/terraform/docs), [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) et [modules](https://developer.hashicorp.com/terraform/language/modules).
- [Provider Google](https://registry.terraform.io/providers/hashicorp/google/latest/docs), [Cloud SQL](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) et [connexion privée](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection).
- [Provider AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs), [EC2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance), [RDS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) et [enregistrement Route 53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record).
