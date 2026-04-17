terraform {
  backend "s3" {
    bucket         = "kijanikiosk-tf-state-2026"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "kijanikiosk-tf-locks"
  }
}