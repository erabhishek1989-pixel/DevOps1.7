resource "azurerm_resource_group" "resource_group" {
  name     = "${var.environment_identifier}-${var.rgname}"
  location = var.rglocation
  tags     = var.rgtags
}