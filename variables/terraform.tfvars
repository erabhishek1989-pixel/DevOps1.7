#---------------- ENVIRONMENT ------------------#
tenant_id                       = "fb973a23-5188-45ab-b4fb-277919443584"
infrastructure_client_id        = "12a25e77-8484-41ff-98c1-e58557bdf161"
infra_client_ent_app__object_id = "a275c283-41dc-482e-9aa7-366964c4a92e"

core_networking_tenant_id       = "fb973a23-5188-45ab-b4fb-277919443584"
core_networking_subscription_id = "1753c763-47da-4014-991c-4b094cababda"

common_tags = {
  Application    = "Tax"
  Owner          = "ServiceLine - Tax"
  Classification = "Company Confidential"
}
#---------------- RESOURCE GROUP ------------------#
resource_groups_map = {
  "rg-tax-uksouth-alteryx" = {
    name     = "rg-tax-uksouth-alteryx"
    location = "UK South"
  }
  "rg-tax-ukwest-alteryx" = {
    name     = "rg-tax-ukwest-alteryx"
    location = "UK West"
  }
  "rg-tax-uksouth-pagero" = {
    name     = "rg-tax-uksouth-pagero"
    location = "UK South"
  }
  "rg-tax-ukwest-pagero" = {
    name     = "rg-tax-ukwest-pagero"
    location = "UK West"
  }
  "rg-tax-uksouth-network" = {
    name     = "rg-tax-uksouth-network"
    location = "UK South"
  }
  "rg-tax-ukwest-network" = {
    name     = "rg-tax-ukwest-network"
    location = "UK West"
  }
  "rg-tax-uksouth-pageroapi" = {
    name     = "rg-tax-uksouth-pageroapi"
    location = "UK South"
  }
  " rg-tax-ukwest-pageroapi" = {
    name     = "rg-tax-ukwest-pageroapi"
    location = "UK West"
  }
}
#---------------- ENTRA ID GROUPS ------------------# TO DO:  APP ID need to be confirmed
EntraID_Groups = {
  "Tax_Pagero_StorageReader" = {
    group_name       = "Tax_Pagero_StorageReader"
    security_enabled = true
    role_assignments = {
      "storage-reader" = {
        scope     = "/subscriptions/91bb7688-5561-4ddf-b353-96ce02e64320"
        role_name = "Storage Blob Data Reader"
      }
    }
  }
  "Tax_Pagero_Keyvault_Secrets_Officer" = {
    group_name       = "Tax_Pagero_Keyvault_Secrets_Officer"
    security_enabled = true
    role_assignments = {
      "keyvault-secrets" = {
        scope     = "/subscriptions/91bb7688-5561-4ddf-b353-96ce02e64320"
        role_name = "Key Vault Secrets Officer"
      }
    }
  }
  "Tax_AMEXPagero_KeyVault_Access" = {
    group_name       = "Tax_AMEXPagero_KeyVault_Access"
    security_enabled = true
    role_assignments = {
      "amexpagero-kv-secrets" = {
        scope     = "/subscriptions/91bb7688-5561-4ddf-b353-96ce02e64320/resourceGroups/d3-rg-tax-uksouth-pageroapi/providers/Microsoft.KeyVault/vaults/d3-kv-tax-pageroapi-uks"
        role_name = "Key Vault Secrets User"
      }
    }
  }
  "Tax_AMEXPagero_Storage_Access" = {
    group_name       = "Tax_AMEXPagero_Storage_Access"
    security_enabled = true
    role_assignments = {
      "amexpagero-storage-reader" = {
        scope     = "/subscriptions/91bb7688-5561-4ddf-b353-96ce02e64320/resourceGroups/d3-rg-tax-uksouth-pageroapi/providers/Microsoft.Storage/storageAccounts/d3sttaxpageroapiuks"
        role_name = "Storage Blob Data Reader"
      }
    }
  }
}
#---------------- KEY VAULTS ------------------#
keyvault_map = {
  "kv-tax-uks-alteryx" = {
    keyvault_name       = "kv-tax-uks-alteryx"
    resource_group_name = "rg-tax-uksouth-alteryx"
    location            = "UK South"
    
    allowed_subnet_ids = [
      {
        virtual_network_key = "vnet-tax-uksouth-0001"
        subnet_name         = "snet-tax-uksouth-keyvault"
      }
    ]
    
    private_endpoint = {
      name                            = "priv-nic-kv-alteryx-uksouth-0001"
      subnet_name                     = "snet-tax-uksouth-keyvault"
      virtual_network_key             = "vnet-tax-uksouth-0001"
      private_service_connection_name = "priv-nic-kv-alteryx-uksouth-0001-svc"
      static_ip                       = null
    }
  }

  "kvtaxukspagero" = {
    keyvault_name       = "kvtaxukspagero"
    resource_group_name = "rg-tax-uksouth-pagero"
    location            = "UK South"
    
    allowed_subnet_ids = [
      {
        virtual_network_key = "vnet-tax-uksouth-0001"
        subnet_name         = "snet-tax-uksouth-keyvault"
      }
    ]
    
    private_endpoint = {
      name                            = "priv-nic-kv-pagero-uksouth-0001"
      subnet_name                     = "snet-tax-uksouth-keyvault"
      virtual_network_key             = "vnet-tax-uksouth-0001"
      private_service_connection_name = "priv-nic-kv-pagero-uksouth-0001-svc"
      static_ip                       = null
    }
  }

  "kv-tax-pageroapi-uks" = {
    keyvault_name       = "kv-tax-pageroapi-uks"
    resource_group_name = "rg-tax-uksouth-pageroapi"
    location            = "UK South"
    
    allowed_subnet_ids = [
      {
        virtual_network_key = "vnet-tax-uksouth-0001"
        subnet_name         = "snet-tax-uksouth-keyvault"
      }
    ]
    
    private_endpoint = {
      name                            = "priv-nic-kv-tax-pageroapi-uksouth-0001"
      subnet_name                     = "snet-tax-uksouth-privateendpoints"
      virtual_network_key             = "vnet-tax-uksouth-0001"
      private_service_connection_name = "priv-nic-kv-tax-pageroapi-uksouth-0001-svc"
      static_ip                       = null
    }
  }
}
#---------------- STORAGE ACCOUNT ------------------#
storage_accounts = {
  "sttaxukspagero" = {
    name                          = "sttaxukspagero"
    resource_group_key            = "rg-tax-uksouth-pagero"
    location                      = "UK South"
    account_kind                  = "StorageV2"
    account_tier                  = "Standard"
    account_replication_type      = "GRS"
    public_network_access_enabled = false
    is_hns_enabled                = true
    sftp_enabled                  = true
    private_endpoint_enabled      = true
    
    virtual_network_key = "vnet-tax-uksouth-0001"
    subnet_name         = "snet-tax-uksouth-storage"
    keyvault_key        = "kvtaxukspagero"
    
    sftp_local_users = {
      "accountone" = {
        name              = "accountone"
        keyvault          = "kvtaxukspagero"
        permission_create = true
        permission_delete = true
        permission_list   = true
        permission_read   = true
        permission_write  = true
      }
    }
  }

  "sttaxpageroapiuks" = {
    name                          = "sttaxpageroapiuks"
    resource_group_key            = "rg-tax-uksouth-pageroapi"
    location                      = "UK South"
    account_kind                  = "StorageV2"
    account_tier                  = "Standard"
    account_replication_type      = "GRS"
    is_hns_enabled                = false
    sftp_enabled                  = false
    public_network_access_enabled = false
    private_endpoint_enabled      = true
    
    virtual_network_key = "vnet-tax-uksouth-0001"
    subnet_name         = "snet-tax-uksouth-storage"
    keyvault_key        = "kv-tax-pageroapi-uks"
    
    sftp_local_users = {}
  }
}
