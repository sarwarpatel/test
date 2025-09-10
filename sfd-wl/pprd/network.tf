provider "azurerm" {
  subscription_id = var.subscription_sfd
  features {}
}

data "azurerm_client_config" "pprdsfd_core" {}

module "resourcegroup_sfd_netw" {
  for_each       = var.resource_groups_sfd_netw
  providers      = { azurerm = azurerm.pprdsfd }
  source         = "../../azure_modules/azure-resource-group-tfmodule"
  application_id = var.application_id
  location       = var.azure_region
  environment    = var.environment
  settings       = each.value
}

#----------------------------------------------------------
# Virtual Network and Subnet
#----------------------------------------------------------
module "networking_sfd" {
  providers           = { azurerm = azurerm.pprdsfd }
  depends_on          = [module.resourcegroup_sfd_netw, module.network_security_groups]
  source              = "../../azure_modules/terraform-azurerm-avm-res-network-virtualnetwork-0.9.2"
  for_each            = var.vnet_name
  settings            = each.value
  application_id      = var.application_id
  location            = var.azure_region
  environment         = var.environment
  routing_domain      = var.routing_domain_sfd
  resource_group_name = module.resourcegroup_sfd_netw[each.value.resource_group_key].name
  dns_servers = {
    dns_servers = each.value.dns_servers
  }
  ddos_protection_plan = {
    id     = data.azurerm_network_ddos_protection_plan.example.id
    enable = true
  }
  enable_telemetry = false
  address_space    = each.value.vnet.address_space
  subnets = {
    for subnet_key, subnet_value in each.value.subnets :
    subnet_key => merge(subnet_value, (
      subnet_value.network_security_group_key != "" ? {
        network_security_group = {
          id = module.network_security_groups[subnet_value.network_security_group_key].resource_id
        },
        route_table = {
          id = module.routetable[subnet_value.route_table_key].resource_id
        }
      } : {}
      ),
      (
        lookup(subnet_value, "security_zone", null) != null ? {
          security_zone = subnet_value.security_zone
        } : {}
      )
    )
  }
}


#----------------------------------------------------------
# Network Security Group
#----------------------------------------------------------
module "network_security_groups" {
  providers           = { azurerm = azurerm.pprdsfd }
  depends_on          = [module.resourcegroup_sfd_netw]
  source              = "../../azure_modules/terraform-azurerm-avm-res-network-networksecuritygroup-main"
  for_each            = var.network_security_groups
  settings            = each.value
  application_id      = var.application_id
  location            = var.azure_region
  environment         = var.environment
  routing_domain      = var.routing_domain_sfd
  security_zone       = each.value.security_zone
  resource_group_name = module.resourcegroup_sfd_netw[each.value.resource_group_key].name
  security_rules      = local.nsg_rules
}
