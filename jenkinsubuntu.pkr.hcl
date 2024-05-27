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
  ami_name       = "Jenkins"
  instance_type  = "t2.small"
  region         = "us-east-1"
  source_ami     = "ami-04b70fa74e45c3917"
  ssh_username   = "ubuntu"
  encrypt_boot   = true
  kms_key_id     = "22ad3ccd-28a1-4d05-ad73-5f284cea93b3"
}

build {
  name = "jenkins"
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
      "sudo ufw enable",
      "sudo ufw allow 8080/tcp"
    ]
  }
}
