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

  extra_tags = {}

  # Storage account mappings
  storage_subnet_mapping = {
    "sttaxukspagero"     = module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-storage"]
    "sttaxuksamexpagero" = module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-amexpagero"]
  }

  storage_keyvault_mapping = {
    "sttaxukspagero"     = module.Key_Vaults["kvtaxukspagero"].keyvault_id
    "sttaxuksamexpagero" = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  }

  private_dns_zone_id = data.terraform_remote_state.y3-core-networking-ci.outputs.dns-core-private-storage-blob-id
}
#--------------- DEPLOYMENT ---------------#

#--------------- Resource Groups ---------------#

module "resource_groups" {
  source = "./modules/resourcegroups"

  for_each               = var.resource_groups_map
  rgname                 = each.value.name
  rglocation             = each.value["location"]
  environment_identifier = var.environment_identifier
  rgtags                 = merge(local.common_tags, local.extra_tags)
}

#--------------- Virtual Networks ---------------#

module "virtual_networks" {
  source   = "./modules/virtual_network"
  for_each = var.virtual_networks

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
  source = "./modules/keyvaults"

  for_each                        = var.keyvault_map
  key_vault_name                  = each.value.keyvault_name
  rg-name                         = each.value["resource_group_name"]
  environment_identifier          = var.environment_identifier
  location                        = each.value.location
  infra_client_ent_app__object_id = var.infra_client_ent_app__object_id
  tenant_id                       = var.tenant_id
  allowed_subnet_ids = [
    module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-keyvault"],
    module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-amexpagero"]
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

#--------------- Entra ID Groups ---------------#

module "EntraID_groups" {
  source           = "./modules/EntraID_Groups"
  for_each         = var.EntraID_Groups
  display_name     = "G_NL_AAD_APP_${var.environment}_${each.value.group_name}"
  security_enabled = each.value["security_enabled"]
  subscription_id  = "/subscriptions/${var.subscription_id}"
}

#--------------- Storage Accounts ---------------#
module "storage_accounts" {
  source   = "./modules/storage_accounts"
  for_each = var.storage_accounts
  # Basic required attributes
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
  #private_endpoint_name         = each.value.private_endpoint_name
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)

  # Explicitly set all required attributes
  subnet_id              = local.storage_subnet_mapping[each.key]
  private_dns_zone_id    = local.private_dns_zone_id
  keyvault_id            = local.storage_keyvault_mapping[each.key]
  environment_identifier = var.environment_identifier

  depends_on = [
    module.Key_Vaults,
    module.virtual_networks,
    module.resource_groups
  ]
}

# Generate Secure Passwords
resource "random_password" "sql_admin_password_amexpagero" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "app_service_secret_amexpagero" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# SQL Server Module
# SQL Server Module with Failover Group
module "sql_server_amexpagero" {
  source = "./Modules/sql_server"  

  sql_server_name               = "${var.environment_identifier}-${var.amexpagero_resources.sql_server_name}"
  sql_databases                 = var.sql_databases_config
  resource_group_name           = "${var.environment_identifier}-rg-tax-uksouth-amexpagero"
  location                      = "UK South"
  sql_admin_username            = var.amexpagero_resources.sql_admin_username
  sql_admin_password            = random_password.sql_admin_password_amexpagero.result
  sql_version                   = var.sql_server_config.version
  minimum_tls_version           = var.sql_server_config.minimum_tls_version
  public_network_access_enabled = var.sql_server_config.public_network_access_enabled
  
  azuread_administrator = {
    login_username              = "G_NL_SQL_ADMIN"
    object_id                   = data.azuread_group.sql_admin_group.object_id
    azuread_authentication_only = false
  }
  
  enable_private_endpoint          = true
  private_endpoint_name            = "${var.environment_identifier}-${var.amexpagero_resources.sql_private_endpoint_name}"
  private_service_connection_name  = "${var.environment_identifier}-${var.amexpagero_resources.sql_private_service_connection_name}"
  subnet_id                        = module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-amexpagero"]
  private_dns_zone_ids             = ["/subscriptions/1753c763-47da-4014-991c-4b094cababda/resourceGroups/y3-rg-core-networking-uksouth-0001/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"]
  
  # Failover Group Configuration
  enable_failover_group                    = var.sql_failover_config != null ? var.sql_failover_config.enabled : false
  secondary_location                       = var.sql_failover_config != null ? var.sql_failover_config.secondary_location : null
  secondary_resource_group_name            = var.sql_failover_config != null ? "${var.environment_identifier}-${var.sql_failover_config.secondary_resource_group}" : null
  secondary_server_name                    = var.sql_failover_config != null ? "${var.environment_identifier}-${var.sql_failover_config.secondary_server_name}" : null
  secondary_subnet_id                      = var.sql_failover_config != null ? module.virtual_networks["vnet-tax-ukwest-0001"].subnet_id[var.sql_failover_config.secondary_subnet_name] : null
  secondary_private_endpoint_name          = var.sql_failover_config != null ? "${var.environment_identifier}-${var.sql_failover_config.secondary_private_endpoint_name}" : null
  secondary_private_service_connection_name = var.sql_failover_config != null ? "${var.environment_identifier}-${var.sql_failover_config.secondary_private_service_connection_name}" : null
  failover_group_name                      = var.sql_failover_config != null ? "${var.environment_identifier}-${var.sql_failover_config.failover_group_name}" : null
  failover_group_read_write_policy = var.sql_failover_config != null ? {
    mode          = "Automatic"
    grace_minutes = var.sql_failover_config.grace_minutes
  } : null
  
  tags = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.virtual_networks]
}
# Service Bus Module
module "service_bus_amexpagero" {
  source = "./Modules/service_bus"

  service_bus_name              = "${var.environment_identifier}-sb-amexpagero-uksouth"
  resource_group_name           = "${var.environment_identifier}-rg-tax-uksouth-amexpagero"
  location                      = "UK South"
  sku                           = var.service_bus_config.sku
  public_network_access_enabled = var.service_bus_config.public_network_access_enabled
  minimum_tls_version           = var.service_bus_config.minimum_tls_version

  # Queues (optional)
  queues = var.service_bus_config.queues

  # Topics (optional)
  topics = var.service_bus_config.topics

  # Subscriptions (optional)
  subscriptions = var.service_bus_config.subscriptions

  # Private endpoint
  enable_private_endpoint         = true
  private_endpoint_name           = "${var.environment_identifier}-pe-sb-amexpagero-uksouth"
  private_service_connection_name = "${var.environment_identifier}-psc-sb-amexpagero-uksouth"
  subnet_id                       = module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-amexpagero"]
  private_dns_zone_ids            = ["/subscriptions/1753c763-47da-4014-991c-4b094cababda/resourceGroups/y3-rg-core-networking-uksouth-0001/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"]

  tags = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.virtual_networks]
}

# Store Service Bus connection string in Key Vault
resource "azurerm_key_vault_secret" "service_bus_connection_string_amexpagero" {
  name         = "service-bus-connection-string"
  value        = module.service_bus_amexpagero.primary_connection_string
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults, module.service_bus_amexpagero]
}


#App Service
module "app_service_amexpagero" {
  source = "./modules/app_service"

  app_service_plan_name = "${var.environment_identifier}-${var.amexpagero_resources.app_service_plan_name}"
  app_service_name      = "${var.environment_identifier}-${var.amexpagero_resources.app_service_name}"
  resource_group_name   = "${var.environment_identifier}-rg-tax-uksouth-amexpagero"
  location              = "UK South"
  sku_name              = var.app_service_config.sku_name
  python_version        = var.app_service_config.python_version
  always_on             = false

  # VNet Integration 
  enable_vnet_integration    = true
  vnet_integration_subnet_id = module.virtual_networks["vnet-tax-uksouth-0001"].subnet_id["snet-tax-uksouth-amexpagero"]

  app_settings = {
    "DATABASE_URL"           = "@Microsoft.KeyVault(SecretUri=${module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id}/secrets/sql-connection-string)"
    "APP_SECRET"             = "@Microsoft.KeyVault(SecretUri=${module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id}/secrets/app-service-secret)"
    "STORAGE_CONNECTION"     = "@Microsoft.KeyVault(SecretUri=${module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id}/secrets/storage-connection-string)"
    "STORAGE_ACCOUNT"        = "@Microsoft.KeyVault(SecretUri=${module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id}/secrets/storage-account-name)"
    "SERVICE_BUS_CONNECTION" = "@Microsoft.KeyVault(SecretUri=${module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id}/secrets/service-bus-connection-string)"
  }


  tags = merge(local.common_tags, local.extra_tags)

  depends_on = [module.resource_groups, module.sql_server_amexpagero, module.Key_Vaults, module.storage_accounts, module.virtual_networks]
}

#--------------- ASSIGNMENTS ---------------#

resource "azurerm_role_assignment" "app_service_keyvault_secrets_user" {
  scope                = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_service_amexpagero.app_service_identity_principal_id
  depends_on           = [module.app_service_amexpagero, module.Key_Vaults]
}

#resource "azurerm_role_assignment" "amexpagero_kv_secrets_officer" {
#  scope                = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
#  role_definition_name = "Key Vault Secrets Officer"
#  principal_id         = module.EntraID_groups["Tax_AMEXPagero_KeyVault_Access"].object_id
#  depends_on = [module.Key_Vaults, module.EntraID_groups]
#}

#resource "azurerm_role_assignment" "amexpagero_storage_access" {
#  scope                = module.storage_accounts["sttaxuksamexpagero"].id
#  role_definition_name = "Storage Blob Data Contributor"
#  principal_id         = module.EntraID_groups["Tax_AMEXPagero_Storage_Access"].object_id
#  depends_on = [module.storage_accounts, module.EntraID_groups]
#}

#--------------- AMEX PAGERO KEY VAULT SECRETS ---------------#

resource "azurerm_key_vault_secret" "storage_connection_string_amexpagero" {
  name         = "storage-connection-string"
  value        = module.storage_accounts["sttaxuksamexpagero"].primary_connection_string #Updated Abhsihek
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults, module.storage_accounts]
}

# Store SQL connection strings in Key Vault (for each database)
resource "azurerm_key_vault_secret" "sql_connection_strings_amexpagero" {
  for_each = var.sql_databases_config

  name         = "sql-connection-string-${each.key}"
  value        = "Server=tcp:${module.sql_server_amexpagero.sql_server_fqdn},1433;Database=${each.value.name};User ID=${var.amexpagero_resources.sql_admin_username};Password=${random_password.sql_admin_password_amexpagero.result};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults, module.sql_server_amexpagero]
}

# Store Failover Group listener endpoint
resource "azurerm_key_vault_secret" "sql_failover_listener_amexpagero" {
  count = var.sql_failover_config != null && var.sql_failover_config.enabled ? 1 : 0

  name         = "sql-failover-listener-endpoint"
  value        = module.sql_server_amexpagero.failover_group_listener_endpoint
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults, module.sql_server_amexpagero]
}

resource "azurerm_key_vault_secret" "app_service_secret_amexpagero" {
  name         = "app-service-secret"
  value        = random_password.app_service_secret_amexpagero.result
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults]
}
resource "azurerm_key_vault_secret" "storage_account_name_amexpagero" {
  name         = "storage-account-name"
  value        = module.storage_accounts["sttaxuksamexpagero"].name
  key_vault_id = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
  depends_on   = [module.Key_Vaults, module.storage_accounts]
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

data "azuread_group" "sql_admin_group" {
  display_name     = "G_NL_SQL_ADMIN"
  security_enabled = true
}

output "amexpagero_sql_server_fqdn" {
  value = module.sql_server_amexpagero.sql_server_fqdn
}

output "amexpagero_app_service_url" {
  value = module.app_service_amexpagero.app_service_default_hostname
}

output "amexpagero_keyvault_id" {
  value = module.Key_Vaults["kv-tax-uks-amexpagero"].keyvault_id
}

output "amexpagero_service_bus_endpoint" {
  value = module.service_bus_amexpagero.service_bus_endpoint
}
output "sql_admin_group_object_id" {
  value       = data.azuread_group.sql_admin_group.object_id
  description = "Object ID of G_NL_SQL_ADMIN group"
}

output "sql_admin_group_display_name" {
  value       = data.azuread_group.sql_admin_group.display_name
  description = "Display name of SQL Admin group"
}