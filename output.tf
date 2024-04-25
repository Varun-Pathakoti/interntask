output "storage_account_primary_connection_string" {
  value = azurerm_storage_account.taskstorage.primary_connection_string
  sensitive = true
}