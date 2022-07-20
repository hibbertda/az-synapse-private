terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "terraform.tfstate"    
  }
}

provider "azurerm" {
  features {

  }
}