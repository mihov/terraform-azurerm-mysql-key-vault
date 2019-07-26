locals {
  name_prefix = var.prefix
  name_suffix = lookup(var.envname, var.my_environment, "-WARNING-UNEXPECTED-ENVIRONMENT")
  key_vault_id = "subscriptions/${var.subscription_id}}/resourceGroups/${var.resource_group.name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
}