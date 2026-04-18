data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

provider "aws" {
  region = var.region
}

locals {
  servers = {
    api = {
      name = "api"
    }
    payments = {
      name = "payments"
    }
    logs = {
      name = "logs"
    }
  }
}

module "app_server" {
  source = "./modules/app_server"

  for_each = local.servers

name          = each.key
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  allowed_cidr  = var.allowed_cidr
  
}