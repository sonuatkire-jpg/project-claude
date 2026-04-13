# S3 Backend Configuration for Terraform State
# IMPORTANT: Read instructions below before uncommenting

# To set up remote state storage:
# 1. Run 'terraform init' without backend first (backend block is commented out)
# 2. Apply to create all infrastructure resources including S3 bucket
# 3. Uncomment the backend block below
# 4. Run 'terraform init -migrate-state' to migrate state to S3

# backend "s3" {
#   bucket = "${var.project_name}-terraform-state-${var.environment}"
#   key    = "${var.project_name}/${var.environment}/terraform.tfstate"
#   region = var.region

#   # DynamoDB table for state locking (optional but recommended)
#   # dynamdb_table = "${var.project_name}-terraform-state-lock"
# }

# To create the state bucket and table first:
# Uncomment the following resources in a separate 'backend-state.tf' file,
# or add them to main.tf, then run terraform apply before uncommenting backend block above.

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${var.project_name}-terraform-state-${var.environment}"

#   versioning {
#     enabled = true
#   }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_key_id = aws_kms_key.terraform_state.key_id
#       }
#       buckets_key_enabled = true
#     }
#   }

#   tags = merge(local.tags, {
#     Name        = "terraform-state"
#     ManagedBy   = "terraform"
#     Criticality = "high"
#   })
# }

# resource "aws_kms_key" "terraform_state" {
#   description             = "${var.project_name} Terraform State Encryption Key"
#   deletion_window_in_days = 10
#   policy = jsonencode({
#     Version : "2012-10-17",
#     Statement : [
#       {
#         Sid    : "EnableKeyRotation",
#         Effect : "Allow",
#         Action : "kms:GenerateDataKey*,kms:Encrypt*,kms:Decrypt*",
#         Resource : "*",
#         Principal : {
#           AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         },
#         Condition : {
#           StringEquals : {
#             "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}"
#           }
#         }
#       },
#       {
#         Sid    : "AllowServiceUse",
#         Effect : "Allow",
#         Action : "kms:GenerateDataKey*,kms:Encrypt*,kms:Decrypt*,kms:DescribeKey",
#         Resource : "*",
#         Principal : {
#           Service : "s3.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(local.tags, {
#     Name      = "terraform-state-key"
#     ManagedBy = "terraform"
#   })
# }

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = "${var.project_name}-terraform-state-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   point_in_time_recovery {
#     enabled = true
#   }

#   server_side_encryption {
#     enabled = true
#   }

#   tags = merge(local.tags, {
#     Name        = "terraform-state-lock"
#     ManagedBy   = "terraform"
#     Criticality = "high"
#   })
# }

# After creating the state bucket and lock table, uncomment the backend block
# and run: terraform init -migrate-state
