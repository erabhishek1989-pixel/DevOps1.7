resource "azurerm_resource_group" "resource_group" {
  name     = "${var.environment_identifier}-${var.rg-name}"
  location = var.location
  tags     = var.tags
}