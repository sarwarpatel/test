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

resource "azurerm_resource_group" "rg_appservice" {
  name     = "rg_appservice"
  location = "Germany West Central"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  kind                = "Linux"
  reserved            = true
  location            = azurerm_resource_group.rg_appservice.location
  resource_group_name = azurerm_resource_group.rg_appservice.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}


resource "azurerm_linux_web_app" "linuxappservice" {
  name                = "test-linux-webapp"
  location            = azurerm_resource_group.rg_appservice.location
  service_plan_id     = azurerm_app_service_plan.appserviceplan.id
  resource_group_name = azurerm_resource_group.rg_appservice.name
  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}
