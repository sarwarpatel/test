
#----------------------------------------------------------
# Variables - Naming Module
#----------------------------------------------------------

variable "azure_region" {
  type        = string
  description = "Azure Region where the resources will be deployed."
}

variable "environment" {
  type        = string
  description = "Deployment environment, such as 'development', 'staging', or 'production'."
}

variable "application_id" {
  type        = string
  description = "(Optional) Application ID associated with the deployment"
  default     = ""
}

variable "subscription_sfd" {
  type        = string
  description = "Azure Subscription to deploy"
}

#-----------------------------------------------------------
# Variables - Resource Group
#----------------------------------------------------------

variable "resource_groups_sfd" {
  description = "A map of prism servers' resource groups to be created, with keys as resource group names and values as their respective properties."
}

variable "resource_groups_sfd_netw" {
  description = "A map of prism servers' resource groups to be created, with keys as resource group names and values as their respective properties."
}

# ----------------------------------------------------------
# Variables - Key Vault
# ----------------------------------------------------------

variable "soft_delete_retention_days" {
  type        = number
  default     = 90
  description = <<DESCRIPTION
The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days.
DESCRIPTION
}

variable "purge_protection_enabled" {
  type    = bool
  default = false
}

variable "key_vault_sfd" {
  description = "A map of tags to assign to resources."
  type        = map(any)
}

variable "days_to_expire" {
  type    = number
  default = 90
}

# ----------------------------------------------------------
# Variables - Networks & Vent
# ----------------------------------------------------------

variable "vnet_name" {
  description = "Name of the virtual network."
}

variable "network_security_groups" {
}

variable "vnet_peers" {
}

variable "route_tables" {
}

variable "routing_domain_sfd" {
  type        = string
  description = "Routing configuration or value used for sfd App ID infra, specifying how traffic should be directed."
  default     = ""
}

variable "ddos_protection_plan_name" {
  description = "DDOS Protection plan name"
  default     = null
}

variable "ddos_protection_plan_rg_name" {
  description = "DDOS Protection plan Resource group name"
  default     = null
}

variable "ddos_protection_plan_subscription" {
  description = "DDOS Protection plan Subscription name"
  default     = null
}

variable "resource_group_key_internal" {
  description = "Resource group key for internal peering"

}
variable "virtual_network_key_internal" {
  description = "Virtual network key for internal peering"

}

variable "nsg_additional_tags" {
  type        = map(string)
  description = "Additional tags to be applied to network security groups, in addition to the tags already applied to the resource group."
  default     = {}
}

# ----------------------------------------------------------
# Variables - Private Endpoint
# ----------------------------------------------------------

variable "private_endpoints" {
  description = "A map of tags to assign to resources."
  #type        = map(any)
}

variable "ip_configurations" {
  type = map(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string, "default")
  }))

  default = {}
}

variable "private_endpoints_sql" {

}

# ----------------------------------------------------------
# Variables - MSSQL Server
# ----------------------------------------------------------
variable "sql_databases" {
  description = "A map of Azure SQL Databases to be created, with keys as database names and values as their respective properties."
  #  type        = map(any)
}

variable "sql_servers" {
  description = "A map of Azure SQL Servers to be created, with keys as server names and values as their respective properties."
  #  type        = map(any)
}
variable "storage_accounts" {

}

# ----------------------------------------------------------
# Variables - ASP and Web Apps
# ----------------------------------------------------------

variable "logic_apps" {

}

variable "logic_app_definition" {
  type        = any
  description = "Logic App definition in JSON format."
  default     = {}
}

variable "app_service_plans" {

}

variable "web_apps" {

}
variable "zone_balancing_enabled" {
  type        = bool
  default     = false
  description = "Should zone balancing be enabled for this App Service Plan? Defaults to `true`."
}

variable "subscriptionid_gwc_hub" {
  description = "Subscription ID for the shp Hub"
  default     = null
}

#---------------------------------
#Storage account CMK configuration
#----------------------------------
variable "cmk_subscription" {
  type        = string
  description = "Azure Platform Subscription containing CMK"
}

variable "cmk_resource_group" {
  type        = string
  description = "Resource group name for Key Vault and managed identity"
}

variable "cmk_key_vault_name" {
  type        = string
  description = "Name of the Key Vault hosting the CMK"
}

variable "cmk_identity_name" {
  type        = string
  description = "User-assigned managed identity used for CMK access"
}
variable "vm_key_name" {
}

variable "st_key_name" {
}
variable "rbac_info_mi" { }

