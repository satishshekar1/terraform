terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.9.0"
    }
  }
}

provider "azurerm" {
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
}

  subscription_id = "e2a27d13-f034-43b8-be00-c049b119cce5"
  client_id       = "aef584f9-4845-4469-b6cf-acfe737602e8"
  client_secret   = "eyz8Q~9MyRETvAyg_zablGsGel.rBPrqGVsl3dAE"
  tenant_id       = "a8254763-273a-4bed-990b-e871b210c40c"
}
