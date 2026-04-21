terraform plan -compact-warnings -no-color -out=plan.tfplan
terraform show -no-color plan.tfplan > plan.txt
