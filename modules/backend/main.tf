# s3_backend/main.tf

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = var.create_dynamodb_table ? 1 : 0
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# s3_backend/variables.tf

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = true
}

variable "create_dynamodb_table" {
  description = "Whether to create the DynamoDB table"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
}

# s3_backend/outputs.tf

output "s3_bucket_name" {
  value       = var.create_s3_bucket ? aws_s3_bucket.terraform_state[0].id : var.bucket_name
  description = "The name of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = var.create_dynamodb_table ? aws_dynamodb_table.terraform_locks[0].id : var.dynamodb_table_name
  description = "The name of the DynamoDB table"
}