environment            = "Development"
environment_identifier = "d3"
subscription_id        = "91bb7688-5561-4ddf-b353-96ce02e64320"

#---------------- NETWORKING ------------------#
virtual_networks_dns_servers = ["10.0.0.116", "172.21.112.10"]

virtual_networks = {
  "vnet-tax-uksouth-0001" = {
    name               = "d3-vnet-tax-uksouth-0001"
    location           = "UK South"
    resource_group_key = "rg-tax-uksouth-network"  
    address_space      = ["10.0.64.0/24"]
    peerings = {
      "tax_uksouth_to_core_uksouth" = {
        name        = "peer_dev_vnet_tax_uksouth_to_y3_core_networking_uksouth"
        remote_peer = false
      },
      "core_uksouth_to_tax_uksouth" = {
        name        = "peer_y3_core_networking_uksouth_to_dev_vnet_tax_uksouth"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-uksouth-storage" = {
        name             = "d3-snet-tax-uksouth-storage"
        address_prefixes = ["10.0.64.0/28"]
      },
      "snet-tax-uksouth-keyvault" = {
        name             = "d3-snet-tax-uksouth-keyvault"
        address_prefixes = ["10.0.64.16/28"]
      },
      "snet-tax-uksouth-appservice" = {
        name             = "d3-snet-tax-uksouth-appservice"
        address_prefixes = ["10.0.64.32/28"]
        delegation       = ["Microsoft.Web/serverFarms"]
      },
      "snet-tax-uksouth-sqlsrv" = {
        name             = "d3-snet-tax-uksouth-sqlsrv"
        address_prefixes = ["10.0.64.48/28"]
      }
    }
    route_tables = {
      "route-tax-uksouth" = {
        name = "d3-route-tax-uksouth-0001"
        routes = {
          "default" = {
            name                   = "default"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.4"
          }
        }
      }
    }
  },
  "vnet-tax-ukwest-0001" = {
    name               = "d3-vnet-tax-ukwest-0001"
    location           = "UK West"
    resource_group_key = "rg-tax-ukwest-network"  
    address_space      = ["10.2.64.0/24"]
    peerings = {
      "tax_ukwest_to_core_ukwest" = {
        name        = "peer_dev_vnet_tax_ukwest_to_y3_core_networking_ukwest"
        remote_peer = false
      },
      "core_ukwest_to_tax_ukwest" = {
        name        = "peer_y3_core_networking_ukwest_to_dev_vnet_tax_ukwest"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-ukwest-storage" = {
        name             = "d3-snet-tax-ukwest-storage"
        address_prefixes = ["10.2.64.0/28"]
      },
      "snet-tax-ukwest-keyvault" = {
        name             = "d3-snet-tax-ukwest-keyvault"
        address_prefixes = ["10.2.64.16/28"]
      },
      "snet-tax-ukwest-sqlsrv" = {
        name             = "d3-snet-tax-ukwest-sqlsrv"
        address_prefixes = ["10.2.64.32/28"]
      }
    }
    route_tables = {
      "route-tax-ukwest" = {
        name = "d3-route-tax-ukwest-0001"
        routes = {
          "default" = {
            name                   = "default"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }
}


# ----------------------SQL --------------#
sql_servers = {
  "amexpagero" = {
    sql_server_name               = "sql-tax-pageroapi-uksouth-0001"
    resource_group_key            = "rg-tax-uksouth-pageroapi"  
    location                      = "UK South"
    sql_admin_username            = "sqladmin"
    enable_azure_ad_admin         = true
    azure_ad_admin_group_name     = "G_NL_SQL_ADMIN"
    azuread_authentication_only   = false
    sql_version                   = "12.0"
    minimum_tls_version           = "1.2"
    public_network_access_enabled = false
    enable_private_endpoint       = true
    
    sql_databases = {
      "primary-db" = {
        name           = "sqldb-tax-pageroapi-uksouth-0001"
        max_size_gb    = 32
        sku_name       = "GP_Gen5_2"
        zone_redundant = false
      }
      "secondary-db" = {
        name           = "sqldb-tax-pageroapi-analytics-uksouth-0001"
        max_size_gb    = 50
        sku_name       = "GP_Gen5_2"
        zone_redundant = false
      }
    }
    
    # Private Endpoint Configuration
    private_endpoint_name           = "priv-nic-sql-tax-pageroapi-uksouth-0001"
    private_service_connection_name = "priv-nic-sql-tax-pageroapi-uksouth-0001-svc"
    subnet_name                     = "snet-tax-uksouth-sqlsrv"
    virtual_network_key             = "vnet-tax-uksouth-0001"  
    private_dns_zone_ids            = ["/subscriptions/1753c763-47da-4014-991c-4b094cababda/resourceGroups/y3-rg-core-networking-uksouth-0001/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"]
    
    # Failover Configuration
    failover_config = {
      enabled                                   = true
      secondary_location                        = "UK West"
      secondary_resource_group_key              = "rg-tax-ukwest-pageroapi" 
      secondary_server_name                     = "sql-tax-pagero-ukwest-0001"
      secondary_subnet_name                     = "snet-tax-ukwest-sqlsrv"
      secondary_virtual_network_key             = "vnet-tax-ukwest-0001"  
      failover_group_name                       = "sqlfg-tax-pageroapi-0001"
      failover_mode                             = "Automatic"
      grace_minutes                             = 60
      secondary_private_endpoint_name           = "priv-nic-sql-tax-pagero-ukwest-0001"
      secondary_private_service_connection_name = "priv-nic-sql-tax-pagero-ukwest-0001-svc"
    }
    
    # Key Vault for secrets
    keyvault_key             = "kv-tax-uks-amexpagero"  
    store_connection_strings = true
  }
}

# ----------------------APP SERVICE --------------------#

app_services = {
  "amexpagero" = {
    app_service_plan_name = "plan-tax-pageroapi-uksouth-0001"
    app_service_name      = "app-tax-pageroapi-uksouth-0001"
    resource_group_key    = "rg-tax-uksouth-pageroapi"
    location              = "UK South"
    sku_name              = "B1"
    python_version        = "3.10"
    always_on             = false
    
    enable_vnet_integration = true
    virtual_network_key     = "vnet-tax-uksouth-0001"
    subnet_name             = "snet-tax-uksouth-appservice"
    
  
    keyvault_secrets = {
      "DATABASE_URL"           = "sql-connection-string-primary-db"
      "APP_SECRET"             = "app-service-secret"
      "STORAGE_CONNECTION"     = "storage-connection-string"
      "STORAGE_ACCOUNT"        = "storage-account-name"
      "SERVICE_BUS_CONNECTION" = "d3-sb-tax-pageroapi-uksouth-0001-connection-string"
    }
    
    # Static app settings 
    static_app_settings = {
      "PYTHON_VERSION" = "3.10"
      "ENVIRONMENT"    = "Development"
    }
    
    keyvault_key = "kv-tax-uks-amexpagero"
  }
}

# ----------------------SERVICE BUS---------------------#
service_buses = {
  "amexpagero" = {
    service_bus_name              = "sb-tax-pageroapi-uksouth-0001"
    resource_group_key            = "rg-tax-uksouth-pageroapi"
    location                      = "UK South"
    sku                           = "Standard"
    capacity                      = 0
    public_network_access_enabled = true  
    minimum_tls_version           = "1.2"
    
    queues = {
      "invoice-queue" = {
        name                  = "invoice-processing"
        max_size_in_megabytes = 1024
        max_delivery_count    = 10
      }
    }
    
    topics = {
      "events-topic" = {
        name                  = "amexpagero-events"
        max_size_in_megabytes = 1024
      }
    }
    
    subscriptions = {
      "invoice-sub" = {
        name               = "invoice-subscription"
        topic_name         = "events-topic"
        max_delivery_count = 10
      }
    }
    
    # No Private Endpoint- Requesed by project team
    enable_private_endpoint = false
    # Optional: Store connection string in Key Vault
    keyvault_key = "kv-tax-uks-amexpagero"
  }
}
