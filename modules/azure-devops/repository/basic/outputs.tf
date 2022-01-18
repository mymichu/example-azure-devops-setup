output "id" {
  value = azuredevops_git_repository.repo.id
}

output "default_branch" {
  value = azuredevops_git_repository.repo.default_branch
}

output "release_branch_prefix" {
  value = local.release_branch_prefix
}