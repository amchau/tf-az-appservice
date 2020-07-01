# -
# - Core object
# -
variable "appservice_plan_key" {
  type = string
  
}
variable "placement" {
  description = "placement"
  default     = "PUB"
  type        = string
}


variable "projectStream" {
  description = "project stream name"
  type        = string
  default = "F4DP"
}

variable "region" {
  type        = string
  description = "region"
}

variable "releaseVersion" {
  description = "releaseVersion"
  default = "0.1.0"
}



variable "owner" {
  description = "owner"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string

}

variable "app_service_location" {
  description = "App Service resources location if different that the resource group's location."
  type        = string
  default     = ""
}

variable "app_service_additional_tags" {
  description = "Additional tags for the App Service resources, in addition to the resource group tags."
  type        = map(string)
  default     = {}
}

variable "app_service_prefix" {
  description = "App Service resourcess name prefix."
  type        = string
}

variable "app_service_rg" {
  description = "The App Service resources group name."
  type        = string
}

# -
# - Main resources
# -
variable "app_service_plan" {
  description = "The App Services plans with their properties."
  type        = map(object({
		                   id = string
											 prefix = string
											 kind = string
											 sku_tier = string
											 sku_capacity = number
											 sku_size = string
											 reserved = bool
											 maximum_elastic_worker_count = number
											 per_site_scaling = bool
										 }))
 default = {}
}

variable "existing_app_service_plan" {
  description = "Existing App Services plans."
  type        = map(object({
    name = string
    resource_group_name = string
  }))
  default = {}
}

variable "active_directory" {

 type = map(object({ 
    client_id = string
    client_secret = string    
    }))
default = {}
 
}

variable "connection_strings" {
    type  = map(object({
        name = string
        type = string
        value = string
    }))
 default = {}
}

variable "identity" {
    type = map(object({
        identity_ids = string
        type = string
    }))
 default = {}
}


variable "site_config" {
    type = map(object({
        always_on = bool
        app_command_line = string 
        default_documents = list(string)
        dotnet_framework_version = string
        ftps_state = string
        http2_enabled = string
        java_container = string
        java_container_version = string
        java_version = string
        linux_fx_version = string
        managed_pipeline_mode = string
        min_tls_version = string
        php_version = string
        python_version = string
        remote_debugging_enabled = bool
        remote_debugging_version = string
        scm_type = string
        use_32_bit_worker_process = bool
        websockets_enabled = bool
        windows_fx_version = string
    }))
  default = {}
}

variable "site_config_ip_restrictions" {
    type = map(object({
        ip_address = string
        virtual_network_subnet_ids = string
    }))
 default = {}
}

variable "site_config_cors" {
    type = map(object({
        allowed_origins = list(string)
        support_credentials = string
    }))
  default = {}
}

variable "storage_accounts" {
    type = map(object({
    access_key = string
    account_name = string
    mount_path = string
    name = string
    share_name = string
    type = string
    }))
  default = {}
}

variable "app_settings" {
    type = map(string)
    default = {}
}

variable "app_service" {
  description = "The App Services with their properties."
 type        = map(object({
  additional_login_params = map(string)
  allowed_external_redirect_urls = list(string)
  client_affinity_enabled = bool
  client_cert_enabled = bool
  default_provider = string
  enabled = bool
  https_only = bool
  id = string
  issuer = string
  runtime_version = string
  token_store_enabled = bool
  token_refresh_extension_hours = string
  unauthenticated_client_action = string
							}))

	default = {}
}

# -
# - Other
# -
variable "null_array" {
  description = ""
  default     = []
}

variable "subnet_id" {
	type = string
	default = null
}
