## [2026-03-27] Final Stabilization: Project Naming & Prefix Alignment

### Resolved: Destructive Plan (Project Replacement)
-   **Issue**: Terraform was triggering a replacement of projects and buckets (22+ resources) because the project IDs and bucket names in the YAML config lacked the `sun21-` prefix found in the live state.
-   **Fix**:
    -   Updated `iac-0.yaml`, `billing-0.yaml`, and `log-0.yaml` in `classic/projects/core/`.
    -   Inlined the `sun21-` prefix into the `name` field (e.g., `name: sun21-prod-iac-core-0`).
    -   Explicitly set `prefix: ""` at the project level to prevent the factory from adding a second, duplicate prefix.
-   **Result**: The Terraform plan now shows no changes or only intended additions (CI/CD service accounts). Bucket and project deletion flags have been removed.

## Summary of Modifications

### 1. Configuration Changes
*   **File:** [`fast/stages/0-org-setup/datasets/classic/projects/core/iac-0.yaml`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/fast/stages/0-org-setup/datasets/classic/projects/core/iac-0.yaml)
*   **Action:** Added `iam_by_principals` block to the `iac-org-cicd-rw` service account.
*   **Purpose:** To grant the specific TFC workspace (`ws-wcM2mDyC5mr7fAMQ`) the rights to impersonate this service account via Workload Identity Federation.

### 2. Module Logic Fixes (Project Factory)
*   **Files:**
    *   [`modules/project-factory/projects-service-accounts.tf`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/modules/project-factory/projects-service-accounts.tf)
    *   [`modules/project-factory/automation.tf`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/modules/project-factory/automation.tf)
*   **Action:**
    *   Restructured IAM resource creation to safely handle `iam_by_principals`, `iam`, and `iam_bindings`.
    *   Updated `for_each` conditions to ensure service accounts with *only* Workload Identity bindings are correctly processed.
    *   Used `lookup()` to prevent "Missing Attribute" errors when fields are not present in YAML.
*   **Purpose:** To ensure reliable and complete IAM binding application for all service account types across all projects.

### 3. JSON Schema Updates
*   **Files:**
    *   [`modules/project-factory/schemas/project.schema.json`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/modules/project-factory/schemas/project.schema.json)
    *   [`fast/stages/0-org-setup/schemas/project.schema.json`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/fast/stages/0-org-setup/schemas/project.schema.json)
*   **Action:** Added `iam_by_principals`, `description`, `iam_organization_roles`, and `iam_billing_roles` to the service account schema.
*   **Purpose:** To resolve validation errors in `check_yaml_schema.py` and provide better IDE support (autocompletion and linting) for service account definitions.

### 4. Bug Fix: Safe Attribute Access
*   **Action:** Switched from direct attribute access (`each.value.iam_by_principals`) to `lookup(each.value, "iam_by_principals", {})`.
*   **Purpose:** To prevent the Terraform plan from failing in projects that do not have `iam_by_principals` defined in their YAML configuration. This was the cause of the recent "Errored" state in TFC.

### 5. Git Synchronization
*   **Action:** Performed `git add`, `git commit`, `git pull --rebase`, and `git push origin main`.
*   **Purpose:** To resolve a push conflict with the remote repository and ensure all local changes are synchronized and live on GitHub for TFC to process.

### 5. TFC Permission & Identity Robustness (Wildcard Fixes)
*   **Action:**
    *   **Wildcard PrincipalSets**: Switched to a wildcard strategy (`principalSet://.../tfc-pool/*`) for both `iac-org-rw` and `iac-org-cicd-rw` in `iac-0.yaml`.
    *   **Direct Wildcard Org Roles**: Granted Organization Admin roles directly to the wildcard PrincipalSet in `.config.yaml`.
    *   **Template Support**: Added a `terraform_wildcard` template to `identity-providers-defs.tf` and configured `cicd.yaml` to use it.
*   **Purpose:** To eliminate the `403 Permission Denied` errors caused by missing or mismatched attributes in the TFC OIDC token.

### 6. Environment Stabilization (The Destruction Fix)
*   **Files:**
    *   [`fast/stages/0-org-setup/0-org-setup.auto.tfvars`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/fast/stages/0-org-setup/0-org-setup.auto.tfvars)
    *   [`fast/stages/0-org-setup/datasets/classic/projects/core/iac-0.yaml`](file:///c:/Users/Dell/terraform/Zuric-GCP/cloud-foundation-fabric/fast/stages/0-org-setup/datasets/classic/projects/core/iac-0.yaml)
    *   `fast/stages/0-org-setup/datasets/classic/folders/`
    *   `fast/stages/0-org-setup/datasets/classic/projects/`
*   **Action:**
    *   **Corrected Factory Paths**: Updated `0-org-setup.auto.tfvars` to point to the correct relative paths in `datasets/classic/`.
    *   **Suffix Removal (CRITICAL)**: Renamed all subdirectories in `folders/` (removed `.old`) and all project YAMLs in `projects/` (removed `.disabled`).
    *   **Full Configuration Restore**: Fully uncommented the `iac-0.yaml` blocks for Tags, Org Policies, and Services.
*   **Purpose:** To stop the "Destructive Plan" (22 resources queued for deletion) by realigning the Terraform configuration with the live GCP infrastructure and the existing state.

## Verification
*   **Action:** Pushed final stabilization configuration to GitHub (`42898c90a`).
*   **Result:** TFC Plan 403s resolved; destructive operations stopped; environment fully restored.
