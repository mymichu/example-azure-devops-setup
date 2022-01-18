
terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }

  required_version = ">= 1.1.0"
}

variable "az_devops_url" {
  type = string
}

variable "az_devops_token"{
  type = string
}

provider "azuredevops" {
  # Remember to specify the org service url and personal access token details below
  org_service_url       = var.az_devops_url
  personal_access_token = var.az_devops_token
}

module "project-a"{
  source              = "./modules/project-a"
}

