environment            = "Development"
environment_identifier = "d3"
subscription_id        = "91bb7688-5561-4ddf-b353-96ce02e64320"

### NETWORKING ###
virtual_networks_dns_servers = ["10.0.0.116", "172.21.112.10"]

virtual_networks = {
  "vnet-tax-uksouth-0001" = {
    name          = "d3-vnet-tax-uksouth-0001"
    location      = "UK South"
    address_space = ["10.0.64.0/24"]
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
    "snet-tax-uksouth-privateendpoints" = {  
    name             = "d3-snet-tax-uksouth-privateendpoints"
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
    name          = "d3-vnet-tax-ukwest-0001"
    location      = "UK West"
    address_space = ["10.2.64.0/24"]
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
    "snet-tax-ukwest-privateendpoints" = { 
    name             = "d3-snet-tax-ukwest-privateendpoints" 
    address_prefixes = ["10.2.64.32/28"]
    }
    route_tables = {
      "route-tax-uksouth" = {
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

# ========== AMEX PAGERO CONFIGURATION ========== #
amexpagero_resources = {
  sql_server_name                         = "sql-amexpagero-uksouth-0001"      # Updated as per Max's suggestion
  sql_database_name                       = "sqldb-amexpagero-uksouth-0001"    # Updated as per Max's suggestion
  sql_admin_username                      = "sqladmin"
  app_service_plan_name                   = "asp-amexpagero-uksouth-0001"
  app_service_name                        = "app-amexpagero-uksouth-0001"
  sql_private_endpoint_name               = "dev-priv-nic-amexpagero-uksouth-0001"
  sql_private_service_connection_name     = "dev-priv-nic-amexpagero-uksouth-0001-svc"
}
sql_server_config = {
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false
}

sql_databases_config = {
  "primary-db" = {
    name           = "sqldb-amexpagero-uksouth-0001"
    max_size_gb    = 32
    sku_name       = "GP_Gen5_2"
    zone_redundant = false
  }
  "secondary-db" = {
    name           = "sqldb-amexpagero-analytics-uksouth-0001"
    max_size_gb    = 50
    sku_name       = "GP_Gen5_2"
    zone_redundant = false
  }
}

sql_failover_config = {
  enabled                                   = true
  secondary_location                        = "UK West"
  secondary_resource_group                  = "rg-tax-ukwest-amexpagero"  
  secondary_server_name                     = "sql-amexpagero-ukwest-0001"      
  secondary_subnet_name                     = "snet-tax-ukwest-privateendpoints"  
  failover_group_name                       = "fog-amexpagero-ukwest-0001"      
  grace_minutes                             = 60
  secondary_private_endpoint_name           = "dev-priv-nic-amexpagero-ukwest-0001"
  secondary_private_service_connection_name = "dev-priv-nic-amexpagero-ukwest-0001-svc"
}

app_service_config = {
  python_version = "3.10"
  sku_name       = "B1"
  sku_tier       = "Basic"
}
# Service bus 
service_bus_config = {
  sku                           = "Standard"
  public_network_access_enabled = true
  minimum_tls_version          = "1.2"
  
  # Define queues (example)
  queues = {
    "invoice-queue" = {
      name                  = "invoice-processing"
      max_size_in_megabytes = 1024
      max_delivery_count    = 10
    }
  }
  
  # Define topics (example)
  topics = {
    "events-topic" = {
      name                  = "amexpagero-events"
      max_size_in_megabytes = 1024
    }
  }
  
  # Define subscriptions (example)
  subscriptions = {
    "invoice-sub" = {
      name       = "invoice-subscription"
      topic_name = "events-topic"
      max_delivery_count = 10
    }
  }
}
