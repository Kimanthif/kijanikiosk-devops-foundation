variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name in AWS"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
}