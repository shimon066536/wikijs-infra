terraform {
  backend "s3" {
    key          = "wikijs-infra/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}