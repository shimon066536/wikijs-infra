mock_provider "aws" {}

run "protected_state_storage" {
  command = plan
  variables {
    bucket_name = "wikijs-test-state-example"
  }
  assert {
    condition     = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    error_message = "State versions must remain recoverable."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.block_public_acls && aws_s3_bucket_public_access_block.terraform_state.block_public_policy && aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls && aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets
    error_message = "State storage must block public access."
  }
}
