packer {
  required_plugins {
    amazon = {
      version = ">=1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  access_key     = ""
  secret_key     = ""
  ami_name       = "Jenkinss"
  instance_type  = "t2.small"
  region         = "us-east-1"
  source_ami     = "ami-04b70fa74e45c3917"
  ssh_username   = "ubuntu"
  encrypt_boot   = true
  kms_key_id     = "{{user `kms_key_id`}}"
}

resource "aws_kms_key" "jenkins_kms_key" {
  description              = "KMS key for encrypting Jenkins AMI"
  deletion_window_in_days  = 7
  enable_key_rotation      = true
  is_enabled               = true
  multi_region             = false
  policy                   = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_iam_policy_document" "kms_key_policy" {
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
}

build {
  name = "jenkinss"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install maven wget unzip -y",
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install jenkins -y",
      "sudo ufw enable ",
      "sudo ufw allow 8080/tcp"
    ]
  }
}
