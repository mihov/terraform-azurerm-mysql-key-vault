provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

terraform {
  required_version = ">= 0.12.0"
}

resource "azurerm_mysql_server" "mysql" {
  name                = "${local.name_prefix}${var.db_server_name}${local.name_suffix}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku {
    name     = var.sku_name
    capacity = var.sku_capacity
    tier     = var.sku_tier
    family   = var.sku_family
  }

  storage_profile {
    storage_mb            = var.storage_mb
    backup_retention_days = var.backup_retention_days
    geo_redundant_backup  = var.geo_redundant_backup
  }

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  version                      = var.mysql_server_version
  ssl_enforcement              = var.enforce_ssl_mysql
}

resource "azurerm_mysql_configuration" "innodb_large_prefix" {
  name                = "innodb_large_prefix"
  resource_group_name = var.resource_group.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = var.server_mysql_configuration.innodb_large_prefix
}

resource "azurerm_mysql_configuration" "character_set_server" {
  name                = "character_set_server"
  resource_group_name = var.resource_group.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = var.server_mysql_configuration.character_set_server
}

resource "azurerm_mysql_configuration" "max_allowed_packet" {
  name                = "max_allowed_packet"
  resource_group_name = var.resource_group.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = var.server_mysql_configuration.max_allowed_packet
}

resource "azurerm_mysql_database" "mysql" {
  name                = "${var.db_name} ${local.name_suffix}"
  resource_group_name = var.resource_group.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = var.charset
  collation           = var.collation
}

resource "azurerm_mysql_firewall_rule" "mysql" {
  name                = "${var.firewall_rule_name}${local.name_suffix}"
  resource_group_name = var.resource_group.name
  server_name         = azurerm_mysql_server.mysql.name
  start_ip_address    = var.start_ip_address
  end_ip_address      = var.end_ip_address
}

resource "azurerm_key_vault_secret" "admin_username" {
  name         = "${azurerm_mysql_database.mysql.name}AdminUsername"
  value        = var.admin_username
  key_vault_id = local.key_vault_id

  tags = {
    environment = var.my_environment
  }
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${azurerm_mysql_database.mysql.name}AdminPassword"
  value        = var.admin_password
  key_vault_id = local.key_vault_id

  tags = {
    environment = var.my_environment
  }
}

resource "azurerm_key_vault_secret" "fqdn" {
  name         = "${azurerm_mysql_database.mysql.name}Fqdn"
  value        = azurerm_mysql_server.mysql.fqdn
  key_vault_id = local.key_vault_id

  tags = {
    environment = var.my_environment
  }
}
