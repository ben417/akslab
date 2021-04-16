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
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.application}-${var.environment}-${var.location_code}-rg"
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
