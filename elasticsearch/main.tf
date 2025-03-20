# Provider Configuration


# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "sai-infra-bootcamp"
  location = "westeurope"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "sai-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "saiaks"
  kubernetes_version  = "1.30.9"

  default_node_pool {
    name       = "agentpool"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "bootcamp"
  }
}

# PostgreSQL Server
resource "azurerm_postgresql_server" "postgresql" {
  name                = "sai-postgresql-server" # Unique name for the PostgreSQL server
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_1" # Basic tier, Gen5 hardware, 1 vCore

  storage_mb                   = 5120 # 5 GB of storage
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login          = "psqladmin" # Admin username
  administrator_login_password = "P@ssw0rd!" # Admin password (change this to a secure value)

  version                      = "11" # PostgreSQL version
  ssl_enforcement_enabled      = true

  tags = {
    environment = "bootcamp"
  }
}

# PostgreSQL Database
resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgresql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Outputs
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "postgresql_server_fqdn" {
  value = azurerm_postgresql_server.postgresql.fqdn
}

output "postgresql_admin_username" {
  value = azurerm_postgresql_server.postgresql.administrator_login
}

output "postgresql_admin_password" {
  value     = azurerm_postgresql_server.postgresql.administrator_login_password
  sensitive = true
}
