variable "aws_region" {
  sensitive = true
  type      = string
  default   = "us-west-2"
}

variable "username" {
  type    = string
  default = "dtksi"
}

variable "password" {
  type    = string
  default = "dtksi"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "debian" {
  ami_name      = "dtksi-debian-12-amd64"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    most_recent = true
    filters = {
      name                = "debian-12-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["136693071363"]
  }
  ssh_username = "admin"
}


build {
  name = "dtksi-aws-debian"
  sources = [
    "source.amazon-ebs.debian"
  ]

  provisioner "file" {
    source      = "./rsa.pub"
    destination = "/tmp/rsa.pub"
  }

  provisioner "shell" {
    inline = [
      # Account Setup
      "sudo passwd -l root",
      "sudo adduser --disabled-password --gecos 'sudo ssh ${var.username}' ${var.username}",
      "echo '${var.username}:${var.password}' | sudo chpasswd",
      "sudo usermod -aG sudo ${var.username}",

      # SSH Setup
      "sudo sed -i '/^#PermitRootLogin/s/^#//; s/yes/no/' /etc/ssh/sshd_config",
      "echo 'RSAAuthentication yes' | sudo tee -a /etc/ssh/sshd_config",
      "echo 'PubkeyAuthentication yes' | sudo tee -a /etc/ssh/sshd_config",
      "echo 'AllowUsers ${var.username}' | sudo tee -a /etc/ssh/sshd_config",
      "sudo sed -i 's/^#Port 22/Port 1337/' /etc/ssh/sshd_config",

      # Set Up SSH Keys for ${var.username}
      "sudo mkdir -p /home/${var.username}/.ssh",
      "sudo cp /tmp/rsa.pub /home/${var.username}/.ssh/authorized_keys",
      "sudo chown -R ${var.username}:${var.username} /home/${var.username}/.ssh",
      "sudo chmod 700 /home/${var.username}/.ssh",
      "sudo chmod 600 /home/${var.username}/.ssh/authorized_keys",
      "sudo systemctl restart ssh",

      # Update and Upgrade system
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt-get install neovim btop -y"
    ]
  }
}
