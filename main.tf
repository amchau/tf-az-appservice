

module "tag" {
  source         = "git::ssh://sede-ds-adp@vs-ssh.visualstudio.com/v3/sede-ds-adp/Platform%20-%20General/sedp-tf-az-tagging?ref=v0.1.0"
  projectStream  = var.projectStream
  environment    = var.environment
  owner          = var.owner
  region         = var.region
  placement      = var.placement
  releaseVersion = var.releaseVersion
}


data "azurerm_resource_group" "rg" {
  name = var.app_service_rg
}

locals {
  location = var.app_service_location == "" ? data.azurerm_resource_group.rg.location : var.app_service_location
  tags     = merge(var.app_service_additional_tags, data.azurerm_resource_group.rg.tags,module.tag.tags_primary)
}

data "azurerm_app_service_plan" "asp1" {
  for_each = var.existing_app_service_plan
  name                = each.value["name"]
  resource_group_name = lookup(each.value, "resource_group_name", data.azurerm_resource_group.rg.name)
}


resource "azurerm_app_service_plan" "asp1" {
  for_each = merge(var.app_service_plan, {})
  name                         = "${var.app_service_prefix}-asp"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = local.location
  kind                         = lookup(each.value, "kind", "elastic")                         
  maximum_elastic_worker_count = lookup(each.value, "maximum_elastic_worker_count", "2") 

  sku {
    tier     = each.value["sku_tier"]                   
    size     = each.value["sku_size"]                   
    capacity = lookup(each.value, "sku_capacity", null) 
  }

  
  reserved         = lookup(each.value, "reserved", null)         
  per_site_scaling = lookup(each.value, "per_site_scaling", null) 
  tags             = local.tags

}

resource "azurerm_app_service" "apps1" {
  for_each = merge(var.app_service, {})
  name                = "${var.app_service_prefix}-appsvc"                                                
  resource_group_name = data.azurerm_resource_group.rg.name                                                                                        
  location            = local.location                                                                                                             
  app_service_plan_id = lookup(merge(azurerm_app_service_plan.asp1, data.azurerm_app_service_plan.asp1),var.appservice_plan_key)["id"] 
  app_settings        =  var.app_settings          
  client_affinity_enabled = lookup(each.value, "client_affinity_enabled", null) 
  client_cert_enabled     = lookup(each.value, "client_cert_enabled", null)     
  enabled                 = lookup(each.value, "enabled", null)                 
  https_only              = lookup(each.value, "https_only", null)                                                                               
  auth_settings {
    enabled = lookup(each.value, "enabled", false) 
    dynamic "active_directory" {
      for_each = merge(var.active_directory,{})
      content {
      client_id = active_directory.value.client_id
      client_secret = active_directory.value.client_secret
    }
    }
    additional_login_params        = lookup(each.value, "additional_login_params", null)        
    allowed_external_redirect_urls = lookup(each.value, "allowed_external_redirect_urls", null) 
    default_provider               = lookup(each.value, "default_provider", null)               
    issuer = lookup(each.value, "issuer", null) 
    runtime_version               = lookup(each.value, "runtime_version", null)               
    token_refresh_extension_hours = lookup(each.value, "token_refresh_extension_hours", null) 
    token_store_enabled           = lookup(each.value, "token_store_enabled", null)           
    unauthenticated_client_action = lookup(each.value, "unauthenticated_client_action", null) 
  }
/*
  dynamic "backup" {
    for_each = lookup(each.value, "backup", [])
    content {
      name                = lookup(backup.value, "name", null)                
      enabled             = lookup(backup.value, "enabled", null)             
      storage_account_url = lookup(backup.value, "storage_account_url", null) 
      dynamic "schedule" {
        for_each = lookup(backup.value, "schedule", {})
        content {
          frequency_interval       = lookup(schedule.value, "frequency_interval", null)       
          frequency_unit           = lookup(schedule.value, "frequency_unit", null)           
          keep_at_least_one_backup = lookup(schedule.value, "keep_at_least_one_backup", null) 
          retention_period_in_days = lookup(schedule.value, "retention_period_in_days", null) 
          start_time               = lookup(schedule.value, "start_time", null)               
        }
      }
    }
  }
*/
  dynamic "storage_account" {
    for_each = merge(var.storage_accounts, {})
    content {
      name         = lookup(storage_account.value, "name", null)         
      type         = lookup(storage_account.value, "type", null)         
      account_name = lookup(storage_account.value, "account_name", null) 
      share_name   = lookup(storage_account.value, "share_name", null)   
      access_key   = lookup(storage_account.value, "access_key", null)   
      mount_path   = lookup(storage_account.value, "mount_path", null)   

    }
  }

  dynamic "connection_string" {
    for_each = merge(var.connection_strings, {})
    content {
      name  = lookup(connection_string.value, "name", null)  
      type  = lookup(connection_string.value, "type", null)  
      value = lookup(connection_string.value, "value", null) 
    }
  }

        
/*
  dynamic "logs" {
    for_each = lookup(each.value, "logs", {})
    content {

      dynamic "application_logs" {
        for_each = lookup(logs.value, "application_logs", {})
        content {
          dynamic "azure_blob_storage" {
            for_each = lookup(application_logs.value, "azure_blob_storage", {})
            content {
              level             = lookup(azure_blob_storage.value, "level", null)             
              sas_url           = lookup(azure_blob_storage.value, "sas_url", null)           
              retention_in_days = lookup(azure_blob_storage.value, "retention_in_days", null) 
            }
          }
        }
      }

      dynamic "http_logs" {
        for_each = lookup(logs.value, "http_logs", {})
        content {
          dynamic "file_system" {
            for_each = lookup(http_logs.value, "file_system", {})
            content {
              retention_in_days = lookup(file_system.value, "retention_in_days", null) 
              retention_in_mb   = lookup(file_system.value, "retention_in_mb", null)   
            }
          }

          dynamic "azure_blob_storage" {
            for_each = lookup(http_logs.value, "azure_blob_storage", {})
            content {
              sas_url           = lookup(azure_blob_storage.value, "sas_url", null)           
              retention_in_days = lookup(azure_blob_storage.value, "retention_in_days", null) 
            }
          }
        }
      }
    }
  }
*/
  dynamic "site_config" {
    for_each = merge(var.site_config, {})
    content {
      always_on        = lookup(site_config.value, "always_on", null)        
      app_command_line = lookup(site_config.value, "app_command_line", null) 

      dynamic "ip_restriction" {
        for_each = merge(var.site_config_ip_restrictions,{})
        content {
          ip_address                = lookup(ip_restriction.value, "ip_address", null)                
          virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null) 
        }
      }

      dynamic "cors" {
        for_each = merge(var.site_config_cors, {})
        content {
          allowed_origins     = lookup(cors.value, "allowed_origins", null)     
          support_credentials = lookup(cors.value, "support_credentials", null) 
        }
      }

      default_documents        = lookup(site_config.value, "default_documents", null)        
      dotnet_framework_version = lookup(site_config.value, "dotnet_framework_version", null) 
      ftps_state               = lookup(site_config.value, "ftps_state", null)               
      http2_enabled            = lookup(site_config.value, "http2_enabled", null)            

      java_version              = lookup(site_config.value, "java_version", null)                                                                                                                                                                                                                                                                                                      
      java_container            = lookup(site_config.value, "java_container", null)                                                                                                                                                                                                                                                                                                    
      java_container_version    = lookup(site_config.value, "java_container_version", null)                                                                                                                                                                                                                                                                                            
      local_mysql_enabled       = lookup(site_config.value, "local_mysql_enabled", null)                                                                                                                                                                                                                                                                                               
      linux_fx_version          = lookup(site_config.value, "linux_fx_version", null) == null ? null : lookup(site_config.value, "linux_fx_version_local_file_path", null) == null ? lookup(site_config.value, "linux_fx_version", null) : "${lookup(site_config.value, "linux_fx_version", null)}|${filebase64(lookup(site_config.value, "linux_fx_version_local_file_path", null))}" 
      windows_fx_version        = lookup(site_config.value, "windows_fx_version", null)                                                                                                                                                                                                                                                                                                
      managed_pipeline_mode     = lookup(site_config.value, "managed_pipeline_mode", null)                                                                                                                                                                                                                                                                                             
      min_tls_version           = lookup(site_config.value, "min_tls_version", null)                                                                                                                                                                                                                                                                                                   
      php_version               = lookup(site_config.value, "php_version", null)                                                                                                                                                                                                                                                                                                       
      python_version            = lookup(site_config.value, "python_version", null)                                                                                                                                                                                                                                                                                                    
      remote_debugging_enabled  = lookup(site_config.value, "remote_debugging_enabled", null)                                                                                                                                                                                                                                                                                          
      remote_debugging_version  = lookup(site_config.value, "remote_debugging_version", null)                                                                                                                                                                                                                                                                                          
      scm_type                  = lookup(site_config.value, "scm_type", null)                                                                                                                                                                                                                                                                                                          
      use_32_bit_worker_process = lookup(site_config.value, "use_32_bit_worker_process", null)                                                                                                                                                                                                                                                                                         
      websockets_enabled        = lookup(site_config.value, "websockets_enabled", null)                                                                                                                                                                                                                                                                                                
    }
  }

  dynamic "identity" {
    for_each = merge(var.identity, {})
    content {
      type         = lookup(identity.value, "type", null)         
      identity_ids = lookup(identity.value, "identity_ids", null) 

    }
  }

  tags = local.tags
}


