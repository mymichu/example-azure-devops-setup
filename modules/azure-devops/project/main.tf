terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
  }
}

resource "azuredevops_project" "project" {
  name               = "${var.name}"
  description        = "${var.description}"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  # Enable or desiable the DevOps fetures below (enabled / disabled)
  features = {
      "boards" = "enabled"
      "repositories" = "enabled"
      "pipelines" = "enabled"
      "testplans" = "disabled"
      "artifacts" = "enabled"
  }
}