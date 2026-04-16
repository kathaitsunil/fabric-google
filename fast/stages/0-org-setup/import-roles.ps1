# Import all custom roles into Terraform state
# Run this from: c:\Users\sunisingh\Terraform\cloud-foundation-fabric\fast\stages\0-org-setup

terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"service_project_network_admin\"]" organizations/254926364766/roles/serviceProjectNetworkAdmin
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"tag_viewer\"]" organizations/254926364766/roles/tagViewer
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"organization_iam_admin\"]" organizations/254926364766/roles/organizationIamAdmin
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"project_iam_viewer\"]" organizations/254926364766/roles/projectIamViewer
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"network_firewall_policies_admin\"]" organizations/254926364766/roles/networkFirewallPoliciesAdmin
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"ngfw_enterprise_viewer\"]" organizations/254926364766/roles/ngfwEnterpriseViewer
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"storage_viewer\"]" organizations/254926364766/roles/storageViewer
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"ngfw_enterprise_admin\"]" organizations/254926364766/roles/ngfwEnterpriseAdmin
terraform import "module.organization[0].google_organization_iam_custom_role.roles[\"organization_admin_viewer\"]" organizations/254926364766/roles/organizationAdminViewer
