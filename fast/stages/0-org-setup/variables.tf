/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "billing_account" {
  description = "Billing account ID."
  type        = string
  default     = "01895E-E57953-1DB141"
}

variable "context" {
  description = "Context-specific interpolations."
  type = object({
    custom_roles                = optional(map(string), {})
    email_addresses             = optional(map(string), {})
    folder_ids                  = optional(map(string), {})
    iam_principals              = optional(map(string), {})
    locations                   = optional(map(string), {})
    kms_keys                    = optional(map(string), {})
    notification_channels       = optional(map(string), {})
    project_ids                 = optional(map(string), {})
    service_account_ids         = optional(map(string), {})
    tag_keys                    = optional(map(string), {})
    tag_values                  = optional(map(string), {})
    vpc_host_projects           = optional(map(string), {})
    vpc_sc_perimeters           = optional(map(string), {})
    workload_identity_pools     = optional(map(string), {})
    workload_identity_providers = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "factories_config" {
  description = "Configuration for the resource factories or external data."
  type = object({
    dataset = optional(string, "datasets/classic")
    paths = optional(object({
      billing_accounts  = optional(string, "billing-accounts")
      cicd_workflows    = optional(string)
      defaults          = optional(string, "defaults.yaml")
      folders           = optional(string, "folders")
      observability     = optional(string, "observability")
      organization      = optional(string, "organization")
      project_templates = optional(string, "templates")
      projects          = optional(string, "projects")
    }), {})
  })
  nullable = false
  default  = {}
}

variable "org_policies_imports" {
  description = "List of org policies to import. These need to also be defined in data files."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "organization" {
  description = "Organization details."
  type = object({
    domain      = string
    id          = number
    customer_id = string
  })
  default = {
    customer_id = "C03b3mev4"
    domain      = "kathaitsun.com"
    id          = 254926364766
  }
}

variable "prefix" {
  description = "Prefix used for resources that need unique names. Use 9 characters max."
  type        = string
  default     = "sun21"
  validation {
    condition     = length(var.prefix) <= 9
    error_message = "Prefix length must be 9 or less."
  }
}
