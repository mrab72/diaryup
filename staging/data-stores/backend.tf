terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-for-maryam"
    key    = "staging/data-stores/terraform.tfstate"
    region = "us-east-1"
  }
}
