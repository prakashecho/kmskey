provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Create a KMS key
resource "aws_kms_key" "kms_ami" {
  description             = "Example KMS Key"
  deletion_window_in_days = 10 # Optional: Set the deletion window for the KMS key
  enable_key_rotation     = true # Optional: Enable automatic key rotation

  # Optional: Configure a key policy
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# Optional: Create an alias for the KMS key
resource "aws_kms_alias" "kms_ami_alias" {
  name          = "alias/example-key-alias"
  target_key_id = aws_kms_key.kms_ami.id
}

# Optional: Define a key policy document
data "aws_iam_policy_document" "kms_key_policy" {
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
  value       = aws_kms_key.kms_ami.arn
  description = "ARN of the created KMS key"
}

# Output the KMS key alias (if configured)
output "kms_key_alias" {
  value       = aws_kms_alias.ams-ami_alias.name
  description = "Alias of the created KMS key"
}
