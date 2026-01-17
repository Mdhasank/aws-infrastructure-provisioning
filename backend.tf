terraform {
  backend "s3" {
    bucket  = "terraform-state-1705431200" 
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
