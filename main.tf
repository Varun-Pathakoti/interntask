terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = ""
  client_id = ""
  client_secret = ""
  tenant_id = ""
  features {
    
  }
}

resource "azurerm_resource_group" "interntask_group" {
  name="interntask-group"
  location="East US"
}





resource "azurerm_storage_account" "taskstorage" {
  name                     = interntaskstorage0180
  resource_group_name      = azurerm_resource_group.interntask_group.name
  location                 = azurerm_resource_group.interntask_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "queue" {
  name                 = "Taskqueue"
  storage_account_name = azurerm_storage_account.taskstorage.name
}

resource "azurerm_storage_container" "container" {
  name                  = "taskblob"
  storage_account_name  = azurerm_storage_account.taskstorage.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "example" {
  name                = "azureapp"
  location            = azurerm_resource_group.interntask_group.location
  resource_group_name = azurerm_resource_group.interntask_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_function_app" "func" {
  name                       = "TaskQueueToBlobFunc"
  location                   = azurerm_resource_group.interntask_group.location
  resource_group_name        = azurerm_resource_group.interntask_group.name
  storage_account_name       = azurerm_storage_account.taskstorage.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_access_key = azurerm_storage_account.taskstorage.primary_access_key

  os_type = "linux"


  app_settings = {
    AzureWebJobsStorage      = azurerm_storage_account.storage.primary_connection_string
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    QUEUE_NAME               = "taskqueue"
    STORAGE_CONTAINER        = "taskblob"
  }
}