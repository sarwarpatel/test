locals {
  // we're using timeadd and we can't pass the day directly need to be hours
  days_to_hours = var.days_to_expire * 24
  // expiration date need to be in a specific format as well
  expiration_date = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "${local.days_to_hours}h")
}

#----------------------------------------------------------
# Resource Group
# ----------------------------------------------------------
module "resourcegroup_sfd" {

  for_each       = var.resource_groups_sfd
  providers      = { azurerm = azurerm.pprdsfd }
  source         = "../../azure_modules/azure-resource-group-tfmodule"
  application_id = var.application_id
  location       = var.azure_region
  environment    = var.environment
  settings       = each.value
}

# module "resourcegroup_cmk" {
#   for_each       = var.resource_groups_cmk
#   providers      = { azurerm = azurerm.cmk }
#   source         = "../../azure_modulesazure-resource-group-tfmodule"
#   application_id = var.application_id
#   location       = var.azure_region
#   environment    = var.environment
#   settings       = each.value
# }

#----------------------------------------------------------
#Key Vault
#----------------------------------------------------------
data "azurerm_client_config" "pprdsfd" {}

resource "random_password" "admin_password_sfd" {
  length           = 22
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  special          = true
}

module "avm_res_keyvault_vault_sfd" {

  providers = { azurerm = azurerm.pprdsfd }
  source    = "../../azure_modules/terraform-azurerm-avm-res-keyvault-vault-0.10.0"

  for_each = var.key_vault_sfd

  settings                    = each.value
  application_id              = var.application_id
  location                    = var.azure_region
  environment                 = var.environment
  tenant_id                   = data.azurerm_client_config.pprdsfd.tenant_id
  resource_group_name         = module.resourcegroup_sfd.resourcegroup03_sfd.name
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled

  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  role_assignments = {
    deployment_user_secrets = { #give the deployment user access to secrets
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.pprdsfd.object_id
    }
  }

  wait_for_rbac_before_key_operations = {
    create = "60s"
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  secrets = {
    admin_password = {
      name            = "adminmysql"
      content_type    = "adminmysql"
      expiration_date = "2025-11-08T00:00:00Z" #75 days, check dates
      not_before_date = "2025-08-25T00:00:00Z"
    }
  }

  secrets_value = {
    admin_password = random_password.admin_password_sfd.result
  }
}


#--------------------------------------
# Data for cmk encrytpion
#---------------------------------------
# data "azuread_service_principal" "mi_objects" {
#   provider     = azuread
#   for_each     = var.rbac_info_mi
#   display_name = each.key


# }

# # Data: Look up Key Vault in CMK hub subscription
# data "azurerm_key_vault" "cmk" {
#   name                = var.cmk_key_vault_name
#   resource_group_name = var.cmk_resource_group
#   provider            = azurerm.cmk
# }
# # Data: Look up Key Vault key in CMK hub subscription
# data "azurerm_key_vault_key" "cmk_key" {
#   name         = var.st_key_name
#   key_vault_id = data.azurerm_key_vault.cmk.id
#   provider     = azurerm.cmk
# }
# # Lookup User Assigned Managed Identity
# data "azurerm_user_assigned_identity" "cmk_mi" {
#   name                = var.cmk_identity_name
#   resource_group_name = var.cmk_resource_group
#   provider            = azurerm.cmk

# }
#----------------------------------------------------------
# Storage Account
#----------------------------------------------------------
module "storage_account" {
  source = "../../azure_modules/terraform-azurerm-avm-res-storage-storageaccount-0.4.0"
  #providers                         = { azurerm = azurerm.mon_target }
  depends_on  = [module.resourcegroup_sfd /*local.storage_cmk*/]
  for_each    = var.storage_accounts
  environment = var.environment
  inc         = each.value.inc
  context     = each.value.context
  #local_market_shortcut             = var.local_market_shortcut
  location                          = var.azure_region
  resource_group_name               = module.resourcegroup_sfd.resourcegroup04_sfd.name
  account_replication_type          = each.value.account_replication_type
  account_tier                      = each.value.account_tier
  access_tier                       = each.value.access_tier
  account_kind                      = each.value.account_kind
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  allowed_copy_scope                = each.value.allowed_copy_scope
  cross_tenant_replication_enabled  = each.value.cross_tenant_replication_enabled
  default_to_oauth_authentication   = each.value.default_to_oauth_authentication
  edge_zone                         = each.value.edge_zone
  https_traffic_only_enabled        = each.value.https_traffic_only_enabled
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  is_hns_enabled                    = each.value.is_hns_enabled
  large_file_share_enabled          = each.value.large_file_share_enabled
  min_tls_version                   = each.value.min_tls_version
  nfsv3_enabled                     = each.value.nfsv3_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  queue_encryption_key_type         = each.value.queue_encryption_key_type
  sftp_enabled                      = each.value.sftp_enabled
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  table_encryption_key_type         = each.value.table_encryption_key_type
  azure_files_authentication        = each.value.azure_files_authentication
  blob_properties                   = each.value.blob_properties
  custom_domain                     = each.value.custom_domain
  managed_identities                = each.value.managed_identities
  immutability_policy               = each.value.immutability_policy
  network_rules                     = each.value.network_rules
  queue_properties                  = each.value.queue_properties
  routing                           = each.value.routing
  sas_policy                        = each.value.sas_policy
  share_properties                  = each.value.share_properties
  static_website                    = each.value.static_website
  timeouts                          = each.value.timeouts
  #   managed_identities = {
  #     system_assigned            = false
  #     user_assigned_resource_ids = [local.storage_cmk[each.key].user_assigned_identity_id]
  #   }
  #   customer_managed_key = {
  #     key_vault_resource_id = local.storage_cmk[each.key].key_vault_resource_id
  #     key_name              = local.storage_cmk[each.key].key_name
  #     user_assigned_identity = {
  #       resource_id = local.storage_cmk[each.key].user_assigned_identity_id
  #     }
  #   }

  #   role_assignments = {
  #     role_assignment_1 = {
  #       role_definition_id_or_name       = "Key Vault Crypto Officer"
  #       principal_id                     = data.azuread_service_principal.mi_objects[each.key].object_id
  #       skip_service_principal_aad_check = false
  #     },
  #     role_assignment_2 = {
  #       role_definition_id_or_name       = "Key Vault Crypto Service Encryption User"
  #       principal_id                     = data.azuread_service_principal.mi_objects[each.key].object_id
  #       skip_service_principal_aad_check = false
  #     },
  #   }

}

#----------------------------------------------------------
#Azure SQL Database Server
#----------------------------------------------------------
module "sql-server" {

  for_each                     = var.sql_servers
  settings                     = each.value
  providers                    = { azurerm = azurerm.pprdsfd }
  source                       = "../../azure_modules/terraform-azurerm-avm-res-sql-server-0.1.5"
  application_id               = var.application_id
  location                     = var.azure_region
  environment                  = var.environment
  resource_group_name          = module.resourcegroup_sfd[each.value.resource_group_key].name
  administrator_login          = each.value.administrator_login
  administrator_login_password = resource.random_password.admin_password_sfd.result
  server_version               = each.value.server_version
  # managed_identities = {
  #   system_assigned = true
  # }
  enable_telemetry = each.value.enable_telemetry

  azuread_administrator = {
    object_id      = each.value.administrator_object_id
    login_username = each.value.administrator_login_username
  }
}

#----------------------------------------------------------
#Azure SQL Database
#----------------------------------------------------------

module "sql-database" {
  depends_on     = [module.sql-server, module.resourcegroup_sfd]
  for_each       = var.sql_databases
  settings       = each.value
  providers      = { azurerm = azurerm.pprdsfd }
  source         = "../../azure_modules/terraform-azurerm-avm-res-sql-server-0.1.5/modules/database"
  application_id = var.application_id
  location       = var.azure_region
  environment    = var.environment
  sql_server = {
    resource_id = module.sql-server[each.value.server_key].resource_id
  }
  sku_name                    = each.value.sku_name
  collation                   = each.value.collation #module.azure-sql.server[each.value.server_key].name
  max_size_gb                 = each.value.max_size_gb
  short_term_retention_policy = each.value.short_term_retention_policy
  long_term_retention_policy  = each.value.long_term_retention_policy
  zone_redundant              = each.value.zone_redundant

  # managed_identities = {
  #   system_assigned = true
  # }

}

#-----------------------------------------------------------
#App Service Plan
#-----------------------------------------------------------
module "app_service_plans" {
  location               = var.azure_region
  for_each               = var.app_service_plans
  settings               = each.value
  depends_on             = [module.resourcegroup_sfd]
  providers              = { azurerm = azurerm.pprdsfd }
  application_id         = var.application_id
  environment            = var.environment
  source                 = "../../azure_modules/terraform-azurerm-avm-res-web-serverfarm-0.7.0"
  resource_group_name    = module.resourcegroup_sfd.resourcegroup01_sfd.name
  sku_name               = each.value.sku_name
  os_type                = each.value.os_type
  zone_balancing_enabled = each.value.zone_balancing_enabled
}

module "azurerm_Linux_web_app" {
  source                      = "../../azure_modules/terraform-azurerm-avm-res-web-site-0.18.0"
  application_id              = var.application_id
  location                    = var.azure_region
  for_each                    = var.web_apps
  settings                    = each.value
  environment                 = var.environment
  depends_on                  = [module.resourcegroup_sfd, module.app_service_plans]
  enable_telemetry            = each.value.enable_telemetry
  resource_group_name         = module.resourcegroup_sfd.resourcegroup01_sfd.name
  kind                        = "webapp" # "Linux" for Linux apps, "functionapp" for Function Apps, "webapp" for Web Apps
  enable_application_insights = "false"
  # Uses an existing app service plan
  os_type                  = each.value.os_type
  https_only               = each.value.https_only
  service_plan_resource_id = module.app_service_plans[each.value.app_service_plan].resource_id

}

module "logic_apps" {
  source                      = "../../azure_modules/terraform-azurerm-avm-res-web-site-0.18.0"
  depends_on                  = [module.resourcegroup_sfd, module.app_service_plans]
  location                    = var.azure_region
  application_id              = var.application_id
  environment                 = var.environment
  settings                    = each.value
  for_each                    = var.logic_apps
  resource_group_name         = module.resourcegroup_sfd.resourcegroup04_sfd.name
  storage_account_access_key  = module.storage_account.storage_account01.storage_account_primary_access_key
  storage_account_name        = module.storage_account.storage_account01.name
  kind                        = "logicapp"
  os_type                     = "Linux"
  service_plan_resource_id    = module.app_service_plans.app_service_plan02.resource_id
  enabled                     = "true"
  virtual_network_subnet_id   = module.networking_sfd[each.value.vnet_key].subnets[each.value.virtual_network_subnet_id].resource_id
  enable_application_insights = "false"
  https_only                  = each.value.https_only
  #public_network_access_enabled = "true"
  site_config = {
    "ip_restriction" = {
      ip_restriction01 = {
        action     = "Allow"
        ip_address = "185.4.97.2/32"
        name       = "AllowedIP"
        priority   = "100"
      }
      ip_restriction02 = {
        action      = "Allow"
        service_tag = "AzureDevOps"
        name        = "Alloweddevops"
        priority    = "101"
      }

    }
  }
}

#----------------------------------------------------------
# Private Endpoint Connections
#----------------------------------------------------------
module "private_endpoint" {
  depends_on                     = [module.resourcegroup_sfd, module.azurerm_Linux_web_app]
  providers                      = { azurerm = azurerm.pprdsfd }
  source                         = "../../azure_modules/terraform-azurerm-avm-res-network-privateendpoint-0.2.0"
  for_each                       = var.private_endpoints
  location                       = var.azure_region
  environment                    = var.environment
  application_id                 = var.application_id
  enable_telemetry               = false
  settings                       = each.value
  resource_group_name            = module.resourcegroup_sfd[each.value.resource_group_key].name
  subnet_resource_id             = module.networking_sfd[each.value.vnet_key].subnets[each.value.subnet_key].resource_id
  private_connection_resource_id = module.azurerm_Linux_web_app[each.value.web_app_key].resource_id
  subresource_names              = each.value.subresource_names
  network_interface_name         = "pep-nic-ipconfig-${each.value.inc}"

  ip_configurations = {
    ip_configuration_1 = {
      name               = "web-pp-pep-ipconfig-${each.value.inc}"
      private_ip_address = cidrhost(module.networking_sfd[each.value.vnet_key].subnets[each.value.subnet_key].subnet_prefixes[0], each.value.private_ip_address_key)
      subresource_name   = "sites"
      member_name        = "sites"
    }
  }
}
module "private_endpoints_sql" {
  depends_on                     = [module.resourcegroup_sfd, module.sql-database]
  providers                      = { azurerm = azurerm.pprdsfd }
  source                         = "../../azure_modules/terraform-azurerm-avm-res-network-privateendpoint-0.2.0"
  for_each                       = var.private_endpoints_sql
  location                       = var.azure_region
  environment                    = var.environment
  application_id                 = var.application_id
  enable_telemetry               = false
  settings                       = each.value
  resource_group_name            = module.resourcegroup_sfd[each.value.resource_group_key].name
  subnet_resource_id             = module.networking_sfd[each.value.vnet_key].subnets[each.value.subnet_key].resource_id
  private_connection_resource_id = module.sql-server[each.value.sql_server_key].resource_id
  subresource_names              = each.value.subresource_names
  network_interface_name         = "pep-nic-ipconfig-${each.value.inc}"

  ip_configurations = {
    ip_configuration_1 = {
      name               = "sql-pp-pep-ipconfig-${each.value.inc}"
      private_ip_address = cidrhost(module.networking_sfd[each.value.vnet_key].subnets[each.value.subnet_key].subnet_prefixes[0], each.value.private_ip_address_key)
      subresource_name   = "sqlserver"
      member_name        = "sqlserver"
    }
  }
}

