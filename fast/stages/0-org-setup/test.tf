Terraform Cloud (TFC) Migration Documentation
1. Why we have done this & Benefits
The migration from local/GCS state file management to Terraform Cloud (TFC) was driven by the need for better security, collaboration, and operational efficiency.

Benefits in Current & Future Workflows
Enhanced Security via Workload Identity: We eliminated the need to generate, download, and store long-lived static GCP Service Account keys. TFC now authenticates to GCP using Workload Identity Federation (WIF), leveraging short-lived, dynamically generated tokens.
Centralized State & Execution: Remote state is natively secured, versioned, and locked by TFC. Team members no longer need to execute terraform apply locally, preventing conflicting runs and "it works on my machine" issues.
Workflow Automation: Pipeline executions (Plan and Apply) are now centrally tracked in TFC's UI, providing a clear audit log of infrastructural changes, along with optional policy enforcements before an apply.
Scalability: As the Cloud Foundation Fabric (CFF) grows, having distinct workspaces in TFC for each stage (0-org-setup, 1-vpcsc, 2-networking, 2-security) prevents blast-radius overlap.
2. What Changes Were Made & In Which Files
The core 0-org-setup stage was extensively refactored to support TFC as the remote backend system instead of the standard GCS buckets.

Modified Files in fast/stages/0-org-setup:

local-providers.tf

Change: Replaced the traditional backend "gcs" block with a cloud { ... } block.
Details: Configured it to point to the terraform-cloud-deployment-GCP organization and locked the workspace to fabric-google.
assets/providers.tf.tpl

Change: Altered the template used to generate the providers.tf for subsequent stages.
Details: Injected the dynamic ${workspace_name} into the terraform { cloud { ... } } configuration instead of writing remote GCS state locations.
output-files.tf

Change: Introduced the mapping of local stage names to their respective TFC Workspaces.
Details: Added the local.tfc_workspaces map to tie "1-vpcsc" to "fabric-google-vpcsc", etc. Modified the of_providers_content local to pass this workspace_name into the assets/providers.tf.tpl renderer.
cicd-workflows.tf / Workload Identity (Overall)

Change: Configured GCP Workload Identity Federation to trust Terraform Cloud.
Details: Allows TFC workspaces to safely impersonate the specific stage service accounts (like cicd-sa-apply and cicd-sa-plan) for deploying resources.
3. How to Add a New Workspace in TFC in the Future
If you want to add a new stage or an entirely new workspace (e.g., 3-project-factory), follow this procedure:

Step 1: Create the Workspace in Terraform Cloud
Navigate to your TFC Organization UI (terraform-cloud-deployment-GCP).
Create a new CLI-driven (or VCS-driven) workspace (e.g., fabric-google-project-factory).
Ensure the TFC workspace has the necessary Workload Identity Environment Variables (like TFC_WORKLOAD_IDENTITY_AUDIENCE, TFC_GCP_PROVIDER_AUTH, TFC_GCP_WORKLOAD_PROVIDER_NAME, and TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL).
Step 2: Update the output-files.tf Map
To ensure your new stage gets the correctly generated providers.tf configuration, modify the mapping in fast/stages/0-org-setup/output-files.tf:

hcl
locals {
  tfc_workspaces = {
    "0-org-setup"  = "fabric-google"
    "1-vpcsc"      = "fabric-google-vpcsc"
    "2-networking" = "fabric-google-net"
    "2-security"   = "fabric-google-sec"
    "3-new-stage"  = "fabric-google-new"  # <-- Add your new workspace mapping here
  }
}
Step 3: Run terraform apply on 0-org-setup
Running apply on the org-setup stage will regenerate the providers.tf file for the new stage in the terraform-cloud-deployment-GCP organization context.
Step 4: Add Workload Identity Bindings (If necessary)
If this new workspace requires a different impersonated Google Service Account, 
ensure that the GCP Workload Identity Pool has a policy allowing the new TFC workspace to impersonate that specific Service Account. 
This is generally handled in the datasets/ configurations or extending cicd-workflows.tf.



The migration from local/GCS state file management to Terraform Cloud (TFC) was driven by the need for better security, collaboration,
and operational efficiency. For same we need to modify below files 


fast/stages/0-org-setup/assets/providers.tf.tpl

Change: Altered the template used to generate the providers.tf for subsequent stages.
Details: Injected the dynamic ${workspace_name} into the terraform { cloud { ... } } configuration instead of writing remote GCS state locations.

fast/stages/0-org-setup/output-files.tf


====================
By updating outputs-files.tf and the providers.tf.tpl template, the 0-org-setup stage will acts as an automated configuration engine.

Here is how the automation works ,

1. When we run terraform apply on 0-org-setup, it loops through all the future stages (1-vpcsc, 2-security, etc.).
2. For each stage, it generates a custom, ready-to-use  providers.tf  file.
3. It will automatically injects the correct workspace_name (e.g., "fabric-google-sec" for 2-security).
4. It will automatically injects the correct Workload Identity service account for that specific stage's permissions.

Instead of manually editing the backend and provider blocks every single time we start a new stage in Terraform Cloud, 
you can simply use the generated providers.tf file for that stage. 
It will automatically connect to the correct TFC workspace and authenticate to GCP with the correct permissions



4. Detailed Benefits & Use Cases: output-files.tf and assets/providers.tf.tpl

The Google Cloud Foundation Fabric (CFF) follows a strictly staged factory pattern where the 0-org-setup stage
is the foundational orchestrator. One of its primary responsibilities is to bootstrap the initialization files 
(specifically providers.tf and backend configurations) for all subsequent execution stages (1-vpcsc, 2-networking, 2-security, etc.).

Instead of manually configuring the Terraform Cloud (TFC) backend in every single stage—which is prone to error and goes 
against the DRY (Don't Repeat Yourself) principle—we centralized this logic in 0-org-setup by modifying two critical files:

fast/stages/0-org-setup/assets/providers.tf.tpl
This is the Terraform template file used by 0-org-setup to programmatically generate the providers.tf for Stage 1, Stage 2, and so on.
We stripped out the old Google Cloud Storage (gcs) backend block and introduced the terraform { cloud { ... } } block. Crucially, instead of hardcoding a workspace, we securely injected a ${workspace_name} variable. This transforms a static file into a dynamic TFC remote backend generator.
output-files.tf (The Execution Engine)

terraform {
  cloud {
    organization = "terraform-cloud-deployment-GCP"
    workspaces {
      name = "${workspace_name}"
    }
  }
}
provider "google" {
  impersonate_service_account = "${service_account}"
  %{~ if try(universe_domain, null) != null ~}
  universe_domain = "${universe_domain}"
  %{~ endif ~}
}
provider "google-beta" {
  impersonate_service_account = "${service_account}"
  %{~ if try(universe_domain, null) != null ~}
  universe_domain = "${universe_domain}"
  %{~ endif ~}


fast/stages/0-org-setup/output-files.tf

This file executes the providers.tf.tpl template, compiles it, and outputs the actual Terraform files to the downstream stage directories.
We introduced the local.tfc_workspaces map. This explicitly binds each local stage name (e.g., "1-vpcsc") to its corresponding dedicated
TFC Workspace (e.g., "fabric-google-vpcsc"). When 0-org-setup runs, the of_providers_content block iterates through the dependent stages
and dynamically injects the correct TFC workspace name into the template.


Use Case: A developer needs to trigger a run in the networking stage (2-networking).
Benefit: By dynamically generating the backend configurations from a single authoritative source (0-org-setup), we ensure every downstream stage is perfectly configured. Developers do not need to manually edit backend.tf files across different stages. This completely eliminates the risk of human error—such as Stage 2 accidentally pointing to Stage 1's TFC workspace—which would lead to disastrous state corruption.
2. Seamless Scalability for New Stages (The Factory Pattern)

Use Case: The team decides to add a brand new stage, like 3-project-factory, for workload deployments.
Benefit: Adopting the new stage into the Terraform Cloud ecosystem takes seconds. The developer only needs to add a single line mapping the new stage to the new TFC workspace in the local.tfc_workspaces map within output-files.tf. Re-running 0-org-setup automatically generates a safe, mathematically isolated remote backend configuration for the new stage. It preserves the clean, opinionated structure of the FAST architecture.
3. Centralized Identity Management Integration

Use Case: Stages need to impersonate specific GCP Service Accounts to deploy resources, securely brokered through TFC Workload Identity Federation.
Benefit: Because output-files.tf also maps and injects the impersonated Google Service Account (${service_account}) into the template alongside the workspace name, it guarantees that TFC workspaces perfectly align with the specific GCP Service Account assigned to that stage. The authentication context and state management context are tightly coupled and generated together.



Why Migrate to TFC for Automation?
Migrating state to Terraform Cloud is not just about storage; it is the foundation for professional Infrastructure as Code (IaC) Automation.

1. Remote Execution (Worker Managed for You)
In a local or GCS-backend setup, automation requires you to manage your own "runners" (e.g., a specific VM or a GitHub Actions runner) and ensure they have the correct Terraform version, plugins, and credentials installed.

TFC Benefit: TFC provides the execution environment. Automation becomes "push-button" because TFC handles the compute, the environment setup, and the cleanup for every run.
2. VCS-Driven Workflows
Automation is most powerful when tied to your version control system (GitHub).

TFC Benefit: TFC connects directly to your repository. A "git push" automatically triggers a terraform plan in the TFC UI, and a "merge" triggers a terraform apply. This creates a seamless CI/CD pipeline without writing complex script wrappers.
3. Secretless Automation via Workload Identity
Storing static GCP Service Account keys (JSON) in CI/CD secrets (like GitHub Secrets) is a major security risk.

TFC Benefit: With the migration to TFC and the configuration of Workload Identity Federation, automation is secretless. TFC workspaces dynamically exchange a TFC token for a temporary GCP token. There are no long-lived keys to rotate or leak.
4. API-Driven Orchestration
For advanced automation (e.g., a Python script or a self-service portal triggering infrastructure), TFC provides a robust REST API.

TFC Benefit: You can automate the creation of workspaces, the setting of variables, and the triggering of runs programmatically, allowing Terraform to be part of a larger automated platform.
5. Concurrent Run Management & Queuing
In a busy team, multiple automated jobs might try to run at once.

TFC Benefit: TFC natively handles run queuing. If an automated process is already running an apply, TFC will queue subsequent requests, preventing state lock contention and ensuring the integrity of your infrastructure.
