terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
  }
}

module "repo"{
  source              = "./basic"
  name                = "${var.name}"
  project          = "${var.project}"
}

resource "azuredevops_build_definition" "b" {
  project_id = "${var.project}"
  name       = "${var.name}"

  repository {
    repo_type = "TfsGit"
    repo_id   = "${module.repo.id}"
    yml_path  = ".ci/azure-pipelines.yml"
  }
}

resource "azuredevops_branch_policy_build_validation" "p" {
  project_id = "${var.project}"

  enabled  = true
  blocking = true

  settings {
    display_name        = "Don't break the build!"
    build_definition_id = azuredevops_build_definition.b.id

    scope {
      repository_id  = "${module.repo.id}"
      repository_ref = "${module.repo.default_branch}"
      match_type     = "Exact"
    }

    scope {
      repository_id  = "${module.repo.id}"
      repository_ref = "${module.repo.release_branch_prefix}"
      match_type     = "Prefix"
    }
  }
}