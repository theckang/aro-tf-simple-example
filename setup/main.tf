terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.50.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.36.0"
    }
 }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "aro-vnet"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "master_subnet" {
  name                                           = "aro-control-subnet"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = ["10.0.0.0/23"]
  private_link_service_network_policies_enabled  = false
  service_endpoints                              = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "worker_subnet" {
  name                                           = "aro-compute-subnet"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.virtual_network.name
  address_prefixes                               = ["10.0.2.0/23"]
  service_endpoints                              = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_role_assignment" "aro_resource_provider_service_principal_network_contributor" {
  scope                = azurerm_virtual_network.virtual_network.id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_resource_provider_id
  skip_service_principal_aad_check = true
}

output "control-subnet" {
  value	    = azurerm_subnet.master_subnet.id
}

output "compute-subnet" {
  value     = azurerm_subnet.worker_subnet.id
}

