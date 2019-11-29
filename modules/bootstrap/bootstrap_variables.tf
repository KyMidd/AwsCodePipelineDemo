##
# Define variables for Azure DevOps Seed Module
##

variable "s3_tfstate_bucket" {
  description = "Name of the S3 bucket used for Terraform state storage"
}
variable "s3_logging_bucket_name" {
  description = "Name of S3 bucket to use for access logging"
}
variable "dynamo_db_table_name" {
  description = "Name of DynamoDB table used for Terraform locking"
}
variable "codebuild_iam_role_name" {
  description = "Name for IAM Role utilized by CodeBuild"
}
variable "codebuild_iam_role_policy_name" {
  description = "Name for IAM policy used by CodeBuild"
}
variable "terraform_codecommit_repo_arn" {
  description = "Terraform CodeCommit git repo ARN"
}
variable "tf_codepipeline_artifact_bucket_arn" {
  description = "Codepipeline artifact bucket ARN"
}
