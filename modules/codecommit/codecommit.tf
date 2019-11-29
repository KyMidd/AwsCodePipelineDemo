# Build AWS CodeCommit git repo
resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = "CodeCommit Terraform repo for demo"
}


# Output the repo info back to main.tf
output "terraform_codecommit_repo_arn" {
  value = aws_codecommit_repository.repo.arn
}
output "terraform_codecommit_repo_name" {
  value = var.repository_name
}
