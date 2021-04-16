variable "location" {
  type = string
}

variable "location_code" {
  type = string
}

variable "application" {
  type = string
}

variable "environment" {
  type = string
}

locals {
  tags = {
    "application" = var.application
    "environment" = var.environment
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.56.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "5be7a915-38a1-4956-8055-13b1d13d9018"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.application}-${var.environment}-${var.location_code}-rg"
  location = var.location

  tags = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.application}-${var.environment}-${var.location_code}-acr"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku                      = "Basic"
  admin_enabled            = false

  tags = local.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.application}-${var.environment}-${var.location_code}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "labaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.principal_id
}

