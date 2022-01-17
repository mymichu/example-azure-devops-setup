terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
  }
}

module "project" {
    source              = "../azure-devops/project"
    name                = "project-a"
    description         = "This project contains all relevant data to build the project a project"
}

module "repo_android" {
  source              = "../azure-devops/repository"
  name                = "android-sdk"
  project          = "${module.project.id}"
}

module "repo_test" {
  source              = "../azure-devops/repository"
  name                = "test"
  project          = "${module.project.id}"
}
