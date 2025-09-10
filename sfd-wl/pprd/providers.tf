provider "azurerm" {
  alias           = "pprdsfd"
  subscription_id = var.subscription_sfd
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = false

    }
  }
}

provider "azapi" {
  alias = "azapi"

}


provider "azurerm" {
  alias           = "localmarket_gwc"
  subscription_id = var.subscriptionid_gwc_hub
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azapi" {
  alias = "logicapp"
  # Configuration options for azapi if needed
}

provider "azurerm" {
  alias           = "ddosplan"
  subscription_id = var.ddos_protection_plan_subscription
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azurerm" {
alias = "cmk"
features {}
subscription_id = var.cmk_subscription

}