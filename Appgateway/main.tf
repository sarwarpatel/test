terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "9e566852-239a-4af3-ba53-72407fcab679"

}

resource "azurerm_resource_group" "rg_appgateway" {
  name     = "rg_appgateway"
  location = "Germany West Central"
}

resource "azurerm_virtual_network" "vnet_appgateway" {
  name                = "vnet_appgateway"
  address_space       = ["10.0.0.192/27"]
  location            = "Germany West Central"
  resource_group_name = azurerm_resource_group.rg_appgateway.name
}

resource "azurerm_subnet" "snet_appgateway" {
  name                 = "snet_appgateway"
  resource_group_name  = azurerm_resource_group.rg_appgateway.name
  virtual_network_name = azurerm_virtual_network.vnet_appgateway.name
  address_prefixes     = ["10.0.0.192/29"]
}

resource "azurerm_public_ip" "pip_appgateway" {
  name                = "pip_appgateway"
  location            = "Germany West Central"
  resource_group_name = azurerm_resource_group.rg_appgateway.name
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgateway"
  location            = "Germany West Central"
  resource_group_name = azurerm_resource_group.rg_appgateway.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.snet_appgateway.id
  }
  frontend_port {
    name = "frontendport"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "appgw-fe-private"
    private_ip_address            = "10.0.0.196"
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.snet_appgateway.id
  }

  # Public IP attached but no listener created for it
  frontend_ip_configuration {
    name                 = "appgw-fe-public"
    public_ip_address_id = azurerm_public_ip.pip_appgateway.id
  }

  backend_address_pool {
    name = "appgw-backendpool"

  }

  backend_http_settings {
    name                  = "appgw-backendhttpsetting"
    port                  = 80
    cookie_based_affinity = "Disabled"
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "appgw-httplistener"
    frontend_ip_configuration_name = "appgw-fe-private"
    frontend_port_name             = "frontendport"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "appgw-routingrule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-httplistener"
    backend_address_pool_name  = "appgw-backendpool"
    backend_http_settings_name = "appgw-backendhttpsetting"
    priority                   = 100
  }
  depends_on = [azurerm_public_ip.pip_appgateway]
}
