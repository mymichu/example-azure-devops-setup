terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
  }
}

locals {
  release_branch_prefix="refs/heads/release"
}


resource "azuredevops_git_repository" "repo" {
  project_id         = "${var.project}"
  name               = "${var.name}"
  default_branch     = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
  // lifecycle {
    // ignore_changes = [
      // # Ignore changes to initialization to support importing existing repositories
      // # Given that a repo now exists, either imported into terraform state or created by terraform,
      // # we don't care for the configuration of initialization against the existing resource
      // initialization,
    // ]
  // }
}


resource "azuredevops_branch_policy_merge_types" "p" {
  project_id = "${var.project}"

  enabled  = true
  blocking = true

  settings {
    allow_squash                  = false
    allow_rebase_and_fast_forward = true
    allow_basic_no_fast_forward   = true
    allow_rebase_with_merge       = true


    scope {
      repository_id  = azuredevops_git_repository.repo.id
      repository_ref = azuredevops_git_repository.repo.default_branch
      match_type     = "Exact"
    }

    scope {
      repository_id  = azuredevops_git_repository.repo.id
      repository_ref = local.release_branch_prefix
      match_type     = "Prefix"
    }
  }
}


resource "azuredevops_branch_policy_work_item_linking" "p" {
  project_id = "${var.project}"

  enabled  = true
  blocking = true

  settings {

    scope {
      repository_id  = azuredevops_git_repository.repo.id
      repository_ref = azuredevops_git_repository.repo.default_branch
      match_type     = "Exact"
    }

    scope {
      repository_id  = azuredevops_git_repository.repo.id
      repository_ref = local.release_branch_prefix
      match_type     = "Prefix"
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "p" {
  project_id = "${var.project}"

  enabled  = true
  blocking = true

  settings {
    reviewer_count     = 1
    submitter_can_vote = false
    last_pusher_cannot_approve = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes = true # OR on_push_reset_all_votes = true
    on_last_iteration_require_vote = false

    scope {
      repository_id  = azuredevops_git_repository.repo.id
      repository_ref = azuredevops_git_repository.repo.default_branch
      match_type     = "Exact"
    }

    scope {
      repository_id  = azuredevops_git_repository.repo.id 
      repository_ref = local.release_branch_prefix
      match_type     = "Prefix"
    }
  }
}

#Max file size of repo is 10 MB
resource "azuredevops_repository_policy_max_file_size" "p" {
  project_id    = "${var.project}"
  repository_ids  = [azuredevops_git_repository.repo.id]
  enabled       = true
  blocking      = true
  max_file_size = 10 
}