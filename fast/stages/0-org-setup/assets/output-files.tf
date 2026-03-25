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

locals {
  
  # Add this map to define your custom TFC workspace names
  tfc_workspaces = {
    "0-org-setup"  = "gcp-glz-org-setup-dev"
    "1-vpcsc"      = "gcp-glz-vpcsc-dev"
    "2-networking" = "gcp-glz-network-dev"
    "2-security"   = "gcp-glz-security-dev"
  }

  of_buckets = {
    for k, v in module.factory.storage_buckets :
    "$storage_buckets:${k}" => v
@@ -117,6 +126,7 @@
      local.of_service_accounts, each.value.service_account, each.value.service_account
    )
    universe_domain = local.of_universe_domain
    workspace_name  = lookup(local.tfc_workspaces, each.key, "gcp-glz-${each.key}-dev")
  })
}

@@ -133,19 +143,20 @@
      local.of_service_accounts, each.value.service_account, each.value.service_account
    )
    universe_domain = local.of_universe_domain
    workspace_name  = lookup(local.tfc_workspaces, each.key, "gcp-glz-${each.key}-dev")
  })
}

resource "local_file" "tfvars" {
  for_each        = toset(local.of_path == null ? [] : keys(local.of_tfvars))
  file_permission = "0644"
  filename        = "${local.of_path}/tfvars/0-${each.key}.auto.tfvars.json"
  content         = jsonencode(local.of_tfvars[each.key])
}

resource "google_storage_bucket_object" "tfvars" {
  for_each = toset(local.output_files.storage_bucket == null ? [] : keys(local.of_tfvars))
  bucket   = local.of_outputs_bucket
  name     = "tfvars/0-${each.key}.auto.tfvars.json"
  content  = jsonencode(local.of_tfvars[each.key])
}
