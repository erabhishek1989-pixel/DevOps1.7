environment            = "Staging"
environment_identifier = "s3"
subscription_id        = "759ab282-0fa0-4eb7-983f-a42a2ae5ba5c"


### NETWORKING ###

virtual_networks_dns_servers = ["10.0.0.116", "172.21.112.10"]

virtual_networks = {
  "vnet-tax-uksouth-0001" = {
    name          = "s3-vnet-tax-uksouth-0001"
    location      = "UK South"
    address_space = ["10.0.65.0/24"]
    peerings = {
      "tax_uksouth_to_core_uksouth" = {
        name        = "peer_staging_vnet_tax_uksouth_to_y3_core_networking_uksouth"
        remote_peer = false
      },
      "core_uksouth_to_tax_uksouth" = {
        name        = "peer_y3_core_networking_uksouth_to_staging_vnet_tax_uksouth"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-uksouth-storage" = {
        name             = "s3-snet-tax-uksouth-storage"
        address_prefixes = ["10.0.65.0/28"]
      },
      "snet-tax-uksouth-keyvault" = {
        name             = "s3-snet-tax-uksouth-keyvault"
        address_prefixes = ["10.0.65.16/28"]
      }

    }
    route_tables = {
      "route-tax-uksouth" = {
        name = "s3-route-tax-uksouth-0001"
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
    name          = "s3-vnet-tax-ukwest-0001"
    location      = "UK West"
    address_space = ["10.2.65.0/24"]
    peerings = {
      "tax_ukwest_to_core_ukwest" = {
        name        = "peer_staging_vnet_tax_ukwest_to_y3_core_networking_ukwest"
        remote_peer = false
      },
      "core_ukwest_to_tax_ukwest" = {
        name        = "peer_y3_core_networking_ukwest_to_staging_vnet_tax_ukwest"
        remote_peer = true
      }
    }
    subnets = {
      "snet-tax-ukwest-storage" = {
        name             = "s3-snet-tax-ukwest-storage"
        address_prefixes = ["10.2.65.0/28"]
      },
      "snet-tax-ukwest-keyvault" = {
        name             = "s3-snet-tax-ukwest-keyvault"
        address_prefixes = ["10.2.65.16/28"]
      }
    }
    route_tables = {
      "route-tax-uksouth" = {
        name = "s3-route-tax-ukwest-0001"
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