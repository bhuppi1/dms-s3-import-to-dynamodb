resource "aws_dynamodb_table" "import_table" {
  name           = var.dynamodb_table_name
  hash_key       = "id"
  write_capacity = var.dynamodb_table_write_capacity
  read_capacity  = var.dynamodb_table_read_capacity

  attribute {
    name = "id"
    type = "S"
  }
}