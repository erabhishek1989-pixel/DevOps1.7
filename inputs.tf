### REMOTE STATES ### 
data "terraform_remote_state" "y3-core-networking-ci" {
  backend = "azurerm"

  config = {
    storage_account_name = "y3stcoreterraformuksouth"
    container_name       = "y3coreterraformuksouth"
    resource_group_name  = "y3-rg-terraform-uksouth-001"
    key                  = "y3-core-networking-ci.tfstate"
    subscription_id      = "c8be5642-d14b-47b4-b9ef-8080116b2ed0"
  }
}

data "azurerm_resource_group" "rg-core-networking-uksouth-0001" {
  name     = "y3-rg-core-networking-uksouth-0001"
  provider = azurerm.y3-core-networking
}

data "azurerm_virtual_network" "vnet-core-uksouth-0001" {
  name                = "y3-vnet-core-uksouth-0001"
  resource_group_name = data.azurerm_resource_group.rg-core-networking-uksouth-0001.name
  provider            = azurerm.y3-core-networking
}

data "azurerm_resource_group" "rg-core-networking-ukwest-0001" {
  name     = "y3-rg-core-networking-ukwest-0001"
  provider = azurerm.y3-core-networking
}

data "azurerm_virtual_network" "vnet-core-ukwest-0001" {
  name                = "y3-vnet-core-ukwest-0001"
  resource_group_name = data.azurerm_resource_group.rg-core-networking-ukwest-0001.name
  provider            = azurerm.y3-core-networking
}

data "terraform_remote_state" "core-monitoring" {
  backend = "azurerm"

  config = {
    storage_account_name = "y3stcoreterraformuksouth"
    container_name       = "azure-core-monitoring"
    resource_group_name  = "y3-rg-terraform-uksouth-001"
    key                  = "production-core-monitoring.tfstate"
    subscription_id      = "c8be5642-d14b-47b4-b9ef-8080116b2ed0"
  }
}