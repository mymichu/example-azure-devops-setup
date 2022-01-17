
terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azuredevops" {
  # Remember to specify the org service url and personal access token details below
  org_service_url       = "https://dev.azure.com/meyermichel/"
  personal_access_token = "TODO"
}

module "project-a"{
  source              = "./modules/project-a"
}

