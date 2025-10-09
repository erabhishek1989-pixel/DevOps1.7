#--------------- PROVIDER DETAILS ---------------#

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azurerm" {
  alias           = "y3-core-networking"
  tenant_id       = "fb973a23-5188-45ab-b4fb-277919443584"
  subscription_id = "1753c763-47da-4014-991c-4b094cababda"
  features {}
}

data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

terraform {
  backend "azurerm" {}
}

#--------------- CURRENT TIMESTAMP ---------------#
resource "time_static" "time_now" {}

#--------------- TAGS ---------------#
locals {
  common_tags = {
    Application    = "Tax"
    Environment    = var.environment
    Owner          = "ServiceLine - Tax"
    Classification = "Company Confidential"
    LastUpdated    = time_static.time_now.rfc3339
  }

  extra_tags              = {}
  private_dns_zone_id     = data.terraform_remote_state.y3-core-networking-ci.outputs.dns-core-private-storage-blob-id
}

#--------------- DEPLOYMENT ---------------#

#--------------- Resource Groups ---------------#
module "resource_groups" {
  source                 = "./Modules/resourcegroups"
  for_each               = var.resource_groups_map
  rg-name                = each.value.name
  location               = each.value["location"]
  environment_identifier = var.environment_identifier
  tags                   = merge(local.common_tags, local.extra_tags)
}

#--------------- Virtual Networks ---------------#
module "virtual_networks" {
  source                                  = "./modules/virtual_network"
  for_each                                = var.virtual_networks
  name                                    = each.value.name
  location                                = each.value.location
  resource_group_name                     = each.value.location == "UK South" ? module.resource_groups["rg-tax-uksouth-network"].rg_name : module.resource_groups["rg-tax-ukwest-network"].rg_name
  address_space                           = each.value.address_space
  virtual_networks_dns_servers            = var.virtual_networks_dns_servers
  peerings                                = each.value.peerings
  subnets                                 = each.value.subnets
  route_tables                            = each.value.route_tables
  y3-rg-core-networking-uksouth-0001_name = data.azurerm_resource_group.rg-core-networking-uksouth-0001.name
  y3-rg-core-networking-ukwest-0001_name  = data.azurerm_resource_group.rg-core-networking-ukwest-0001.name
  y3-vnet-core-uksouth-0001_id            = data.azurerm_virtual_network.vnet-core-uksouth-0001.id
  y3-vnet-core-uksouth-0001_name          = data.azurerm_virtual_network.vnet-core-uksouth-0001.name
  y3-vnet-core-ukwest-0001_id             = data.azurerm_virtual_network.vnet-core-ukwest-0001.id
  y3-vnet-core-ukwest-0001_name           = data.azurerm_virtual_network.vnet-core-ukwest-0001.name

  providers = {
    azurerm.y3-core-networking = azurerm.y3-core-networking
  }

  depends_on = [module.resource_groups]
}

#--------------- Key Vaults ---------------#
module "Key_Vaults" {
  source                          = "./Modules/keyvaults"
  for_each                        = var.keyvault_map
  key_vault_name                  = each.value.keyvault_name
  rg-name                         = each.value["resource_group_name"]
  environment_identifier          = var.environment_identifier
  location                        = each.value.location
  infra_client_ent_app__object_id = var.infra_client_ent_app__object_id
  tenant_id                       = var.tenant_id
  
  allowed_subnet_ids = [
    for subnet in each.value.allowed_subnet_ids :
    module.virtual_networks[subnet.virtual_network_name].subnet_id[subnet.subnet_name]
  ]
  
  private_endpoint = {
    name                            = each.value.private_endpoint.name
    subnet_id                       = module.virtual_networks["${each.value.private_endpoint.virtual_network_name}"].subnet_id["${each.value.private_endpoint.subnet_name}"]
    private_dns_zone_id             = data.terraform_remote_state.y3-core-networking-ci.outputs.dns-core-private-keyvault-id
    private_service_connection_name = "${each.value.private_endpoint.name}-svc-connection"
    static_ip                       = each.value.private_endpoint.static_ip
  }
  tags = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.virtual_networks]
}

#--------------- Storage Accounts ---------------#
module "storage_accounts" {
  source                        = "./Modules/storage_accounts"
  for_each                      = var.storage_accounts
  name                          = "${var.environment_identifier}${each.value.name}"
  resource_group_name           = "${var.environment_identifier}-${each.value.resource_group_name}"
  location                      = each.value.location
  account_replication_type      = each.value.account_replication_type
  account_tier                  = each.value.account_tier
  account_kind                  = each.value.account_kind
  is_hns_enabled                = each.value.is_hns_enabled
  sftp_enabled                  = each.value.sftp_enabled
  sftp_local_users              = each.value.sftp_local_users
  private_endpoint_enabled      = each.value.private_endpoint_enabled
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  subnet_id                     = module.virtual_networks[each.value.virtual_network_name].subnet_id[each.value.subnet_name]
  private_dns_zone_id           = local.private_dns_zone_id
  keyvault_id                   = module.Key_Vaults[each.value.keyvault_name].keyvault_id
  environment_identifier        = var.environment_identifier

  depends_on = [module.Key_Vaults, module.virtual_networks, module.resource_groups]
}

#--------------- Entra ID Groups ---------------#
module "EntraID_groups" {
  source           = "./modules/EntraID_Groups"
  for_each         = var.EntraID_Groups
  display_name     = each.value.group_name
  security_enabled = each.value.security_enabled
  subscription_id  = "/subscriptions/${var.subscription_id}"
  
  # Pass specific resource IDs for role assignments
  keyvault_id_for_amexpagero = each.key == "Tax_AMEXPagero_KeyVault_Access" ? module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id : null
  storage_id_for_amexpagero  = each.key == "Tax_AMEXPagero_Storage_Access" ? module.storage_accounts["sttaxuksamexpagero"].id : null
  
  depends_on = [module.Key_Vaults, module.storage_accounts]
}

#--------------- SQL SERVERS ---------------#
data "azuread_group" "sql_admin_groups" {
  for_each = {
    for k, v in var.sql_servers : k => v 
    if v.enable_azure_ad_admin && v.azure_ad_admin_group_name != null
  }
  display_name     = each.value.azure_ad_admin_group_name
  security_enabled = true
}

#--------------- SQL SERVERS ---------------#

# Lookup Azure AD groups for SQL admins
data "azuread_group" "sql_admin_groups" {
  for_each = {
    for k, v in var.sql_servers : k => v 
    if v.enable_azure_ad_admin && v.azure_ad_admin_group_name != null
  }
  display_name     = each.value.azure_ad_admin_group_name
  security_enabled = true
}

module "sql_servers" {
  source   = "./Modules/sql_server"
  for_each = var.sql_servers

  sql_server_name               = "${var.environment_identifier}-${each.value.sql_server_name}"
  sql_databases                 = each.value.sql_databases
  resource_group_name           = "${var.environment_identifier}-${each.value.resource_group_name}"
  location                      = each.value.location
  sql_admin_username            = each.value.sql_admin_username
  # NO sql_admin_password HERE!
  sql_version                   = each.value.sql_version
  minimum_tls_version           = each.value.minimum_tls_version
  public_network_access_enabled = each.value.public_network_access_enabled

  azuread_administrator = each.value.enable_azure_ad_admin && each.value.azure_ad_admin_group_name != null ? {
    login_username              = each.value.azure_ad_admin_group_name
    object_id                   = data.azuread_group.sql_admin_groups[each.key].object_id
    azuread_authentication_only = false
  } : null

  enable_private_endpoint         = each.value.enable_private_endpoint
  private_endpoint_name           = "${var.environment_identifier}-${each.value.private_endpoint_name}"
  private_service_connection_name = "${var.environment_identifier}-${each.value.private_service_connection_name}"
  subnet_id                       = module.virtual_networks[each.value.vnet_name].subnet_id[each.value.subnet_name]
  private_dns_zone_ids            = each.value.private_dns_zone_ids

  enable_failover_group                     = each.value.failover_config != null ? each.value.failover_config.enabled : false
  secondary_location                        = each.value.failover_config != null ? each.value.failover_config.secondary_location : null
  secondary_resource_group_name             = each.value.failover_config != null ? "${var.environment_identifier}-${each.value.failover_config.secondary_resource_group}" : null
  secondary_server_name                     = each.value.failover_config != null ? "${var.environment_identifier}-${each.value.failover_config.secondary_server_name}" : null
  secondary_subnet_id                       = each.value.failover_config != null ? module.virtual_networks[each.value.failover_config.secondary_vnet_name].subnet_id[each.value.failover_config.secondary_subnet_name] : null
  secondary_private_endpoint_name           = each.value.failover_config != null ? "${var.environment_identifier}-${each.value.failover_config.secondary_private_endpoint_name}" : null
  secondary_private_service_connection_name = each.value.failover_config != null ? "${var.environment_identifier}-${each.value.failover_config.secondary_private_service_connection_name}" : null
  failover_group_name                       = each.value.failover_config != null ? "${var.environment_identifier}-${each.value.failover_config.failover_group_name}" : null
  failover_group_read_write_policy = each.value.failover_config != null ? {
    mode          = "Automatic"
    grace_minutes = each.value.failover_config.grace_minutes
  } : null

  keyvault_id              = module.Key_Vaults[each.value.keyvault_name].keyvault_id
  store_connection_strings = each.value.store_connection_strings

  tags = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.virtual_networks, module.Key_Vaults]
}

#--------------- Service Bus ---------------#
module "service_buses" {
  source                          = "./Modules/service_bus"
  for_each                        = var.service_buses
  service_bus_name                = "${var.environment_identifier}-${each.value.service_bus_name}"
  resource_group_name             = "${var.environment_identifier}-${each.value.resource_group_name}"
  location                        = each.value.location
  sku                             = each.value.sku
  public_network_access_enabled   = each.value.public_network_access_enabled
  minimum_tls_version             = each.value.minimum_tls_version
  queues                          = each.value.queues
  topics                          = each.value.topics
  subscriptions                   = each.value.subscriptions
  enable_private_endpoint         = each.value.enable_private_endpoint
  private_endpoint_name           = "${var.environment_identifier}-${each.value.private_endpoint_name}"
  private_service_connection_name = "${var.environment_identifier}-${each.value.private_service_connection_name}"
  subnet_id                       = module.virtual_networks[each.value.virtual_network_name].subnet_id[each.value.subnet_name]
  private_dns_zone_ids            = each.value.private_dns_zone_ids
  keyvault_id                     = module.Key_Vaults[each.value.keyvault_name].keyvault_id
  tags                            = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.virtual_networks, module.Key_Vaults]
}

#--------------- App Service ---------------#
module "app_services" {
  source                     = "./Modules/app_service"
  for_each                   = var.app_services
  app_service_plan_name      = "${var.environment_identifier}-${each.value.app_service_plan_name}"
  app_service_name           = "${var.environment_identifier}-${each.value.app_service_name}"
  resource_group_name        = "${var.environment_identifier}-${each.value.resource_group_name}"
  location                   = each.value.location
  sku_name                   = each.value.sku_name
  python_version             = each.value.python_version
  always_on                  = each.value.always_on
  enable_vnet_integration    = each.value.enable_vnet_integration
  vnet_integration_subnet_id = each.value.enable_vnet_integration ? module.virtual_networks[each.value.virtual_network_name].subnet_id[each.value.subnet_name] : null
  app_settings               = each.value.app_settings
  keyvault_id                = module.Key_Vaults[each.value.keyvault_name].keyvault_id
  tags                       = merge(local.common_tags, local.extra_tags)

  depends_on = [
    module.resource_groups, 
    module.sql_servers, 
    module.Key_Vaults, 
    module.storage_accounts, 
    module.virtual_networks,
    module.service_buses
  ]
}

#--------------- OUTPUTS ---------------#
output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

output "object_id" {
  value = data.azuread_client_config.current.object_id
}

output "current_time" {
  value = time_static.time_now.rfc3339
}

output "amexpagero_sql_server_fqdn" {
  value = module.sql_servers["amexpagero"].sql_server_fqdn
}

output "amexpagero_app_service_url" {
  value = module.app_services["amexpagero"].app_service_default_hostname
}

output "amexpagero_keyvault_id" {
  value = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
}

output "amexpagero_service_bus_endpoint" {
  value = module.service_buses["amexpagero"].service_bus_endpoint
}

output "sql_servers_fqdns" {
  value = {
    for k, v in module.sql_servers : k => v.sql_server_fqdn
  }
  description = "FQDNs of all SQL servers"
}

output "sql_failover_listeners" {
  value = {
    for k, v in module.sql_servers : k => v.failover_group_listener_endpoint
    if var.sql_servers[k].failover_config != null && var.sql_servers[k].failover_config.enabled
  }
  description = "Failover group listener endpoints"
  sensitive   = false
}