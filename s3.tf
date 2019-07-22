resource "aws_s3_bucket" "dynamodb_import_bucket" {
  bucket = "dynamodb-import-bucket"
}

resource "aws_s3_bucket_policy" "dynamodb_import_bucket" {
  bucket = aws_s3_bucket.dynamodb_import_bucket.id
  policy = data.aws_iam_policy_document.import_bucket_policy.json
}