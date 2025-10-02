# Introduction

This is the Terraform code for configuring the tax environment

# Getting Started

# Build and Test

#### NOTE: The code examples below are for the development environment, change the file referenced in backend-config="key" in the init command and the tfvars file in the plan command to the correct files for staging/test/production.

To run the code (plan only) do the following:
Make sure you have pulled the latest for the branch you are running Terraform on
Open a Powershell prompt, change to the folder containing the tax Terraform code and run

```PowerShell
az login
```

From the list of available subscriptions, locate the Y3-APP-TAX subscription and enter the number at the prompt

Now run the following to connect and initialise your session to the state file

```
terraform init -backend-config="storage_account_name=y3stcoreterraformuksouth" -backend-config="container_name=azure-app-tax" -backend-config="key=development-app-tax.tfstate" -backend-config="resource_group_name=y3-rg-terraform-uksouth-001" -backend-config="subscription_id=c8be5642-d14b-47b4-b9ef-8080116b2ed0" -reconfigure -upgrade
```

Assuming there are no errors, run

```terraform
terraform validate
```

Once again, assuming no errors, run:

```terraform
terraform plan -var-file="variables\development.tfvars" -var-file="variables\terraform.tfvars"
```

# Contribute

To modify the code, create a feature or bugfix branch off the appropriate release branch. Update the variables or code as appropriate and run the Terraform init, validate and plan commands to test the changes against the development environment.
