variable "project" {
  description = "The project id to which this repository belongs"
  type = string
}

variable "name" {
  description = "Name of the repository"
  type        = string
  sensitive   = true
}

