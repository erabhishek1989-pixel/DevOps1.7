#---------------- ENVIRONMENT ------------------#
tenant_id                       = "fb973a23-5188-45ab-b4fb-277919443584"
infrastructure_client_id        = "12a25e77-8484-41ff-98c1-e58557bdf161"
infra_client_ent_app__object_id = "9bcf1bd1-59a7-4b70-a5a2-52931d9238d8"

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
  "rg-tax-uksouth-amexpagero" = {
    name     = "rg-tax-uksouth-amexpagero"
    location = "UK South"
  }
  "rg-tax-ukwest-amexpagero" = {
    name     = "rg-tax-ukwest-amexpagero"
    location = "UK West"
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

  "kv-tax-uks-amexpagero" = {
    keyvault_name       = "kv-tax-uks-amexpagero"
    resource_group_name = "rg-tax-uksouth-amexpagero"
    location            = "UK South"
    
    allowed_subnet_ids = [
      {
        virtual_network_key = "vnet-tax-uksouth-0001"
        subnet_name         = "snet-tax-uksouth-keyvault"
      }
    ]
    
    private_endpoint = {
      name                            = "priv-nic-kv-amexpagero-uksouth-0001"
      subnet_name                     = "snet-tax-uksouth-privateendpoints"
      virtual_network_key             = "vnet-tax-uksouth-0001"
      private_service_connection_name = "priv-nic-kv-amexpagero-uksouth-0001-svc"
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

  "sttaxuksamexpagero" = {
    name                          = "sttaxuksamexpagero"
    resource_group_key            = "rg-tax-uksouth-amexpagero"
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
    keyvault_key        = "kv-tax-uks-amexpagero"
    
    sftp_local_users = {}
  }
}