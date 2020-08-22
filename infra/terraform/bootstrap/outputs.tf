# outputs.tf

output "s3_bucket_arn" {
  value       = aws_s3_bucket.toptal-3tier-tf-state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.toptal-3tier-tf-locks.name
  description = "The name of the DynamoDB table"
}