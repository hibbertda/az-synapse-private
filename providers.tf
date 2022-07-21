terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
    key                  = "terraform.tfstate"    
  }
}

provider "azurerm" {
  features {

  }
}