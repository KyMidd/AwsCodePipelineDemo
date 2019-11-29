# Require TF version to be same as or greater than 0.12.16
terraform {
  required_version = ">=0.12.16"
  backend "s3" {
    bucket         = "kyler-codebuild-demo-terraform-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "codebuild-dynamodb-terraform-locking"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
  assume_role {
    # Remember to update this account ID to yours
    role_arn     = "arn:aws:iam::718626770228:role/TerraformAssumedIamRole"
    session_name = "terraform"
  }
}


## Step 1: Build an IAM user with administrative rights
# Export the access key and secret access key into global bash variables. The commands will look like this:
# export AWS_ACCESS_KEY_ID="AKIA2OULU2K4324HLYFNU"
# export AWS_SECRET_ACCESS_KEY="b8ma12345678901234567890toWCOjo"


## Step 2: Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                              = "./modules/bootstrap"
  s3_tfstate_bucket                   = "kyler-codebuild-demo-terraform-tfstate"
  s3_logging_bucket_name              = "kyler-codebuild-demo-logging-bucket"
  dynamo_db_table_name                = "codebuild-dynamodb-terraform-locking"
  codebuild_iam_role_name             = "CodeBuildIamRole"
  codebuild_iam_role_policy_name      = "CodeBuildIamRolePolicy"
  terraform_codecommit_repo_arn       = module.codecommit.terraform_codecommit_repo_arn
  tf_codepipeline_artifact_bucket_arn = module.codepipeline.tf_codepipeline_artifact_bucket_arn
}

## Step 3: Build a CodeCommit git repo
module "codecommit" {
  source          = "./modules/codecommit"
  repository_name = "CodeCommitTerraform"
}


## Step 4: Build CodeBuild projects for Terraform Plan and Terraform Apply
module "codebuild" {
  source                                 = "./modules/codebuild"
  codebuild_project_terraform_plan_name  = "TerraformPlan"
  codebuild_project_terraform_apply_name = "TerraformApply"
  s3_logging_bucket_id                   = module.bootstrap.s3_logging_bucket_id
  codebuild_iam_role_arn                 = module.bootstrap.codebuild_iam_role_arn
  s3_logging_bucket                      = module.bootstrap.s3_logging_bucket
}


## Step 5: Build a CodePipeline
module "codepipeline" {
  source                               = "./modules/codepipeline"
  tf_codepipeline_name                 = "TerraformCodePipeline"
  tf_codepipeline_artifact_bucket_name = "kyler-codebuild-demo-artifact-bucket-name"
  tf_codepipeline_role_name            = "TerraformCodePipelineIamRole"
  tf_codepipeline_role_policy_name     = "TerraformCodePipelineIamRolePolicy"
  terraform_codecommit_repo_name       = module.codecommit.terraform_codecommit_repo_name
  codebuild_terraform_plan_name        = module.codebuild.codebuild_terraform_plan_name
  codebuild_terraform_apply_name       = module.codebuild.codebuild_terraform_apply_name
}
