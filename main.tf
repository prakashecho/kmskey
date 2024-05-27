provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Create a KMS key
resource "aws_kms_key" "ami1_key" {
  description             = "Me KMS Key"
  deletion_window_in_days = 10 # Optional: Set the deletion window for the KMS key
  enable_key_rotation     = true # Optional: Enable automatic key rotation

  # Optional: Configure a key policy
  policy = data.aws_iam_policy_document.ami_key_policy.json
}

# Optional: Create an alias for the KMS key
resource "aws_kms_alias" "ami1_key_alias" {
  name          = "alias/ami1_key-alias"
  target_key_id = aws_kms_key.ami_key.id
}

# Optional: Define a key policy document
data "aws_iam_policy_document" "ami1_key_policy" {
  # Allow the current account's root user to perform KMS operations
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Optionally, you can add statements to allow other AWS accounts or IAM roles/users to use the KMS key
}

# Get the current account ID
data "aws_caller_identity" "current" {}

# Output the KMS key ARN
output "kms_key_arn" {
  value       = aws_kms_key.ami1_key.arn
  description = "ARN of the created KMS key"
}

# Output the KMS key alias (if configured)
output "kms_key_alias" {
  value       = aws_kms_alias.ami1_key_alias.name
  description = "Alias of the created KMS key"
}
