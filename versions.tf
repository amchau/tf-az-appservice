terraform {
  required_version = "= 0.12.26"
}


provider "azurerm" {
  version = "=2.14.0"
  features {}
	skip_provider_registration = true
}
