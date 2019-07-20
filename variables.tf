variable "csv_delimiter" {
  default = "|"
}

variable "csv_row_delimiter" {
  default = "\\n"
}

variable "dynamodb_table_name" {
  default = "test"
}

variable "dynamodb_table_write_capacity" {
  default = "1"
}

variable "dynamodb_table_read_capacity" {
  default = "1"
}

variable "dms_replication_instance_type" {
  default = "dms.t2.large"
}

variable "source_endpoint_id" {
  default = "s3-origin"
}

variable "target_endpoint_id" {
  default = "dynamodb-target"
}

variable "replication_instance_id" {
  default = "replication-instance"
}

variable "replication_task_id" {
  default = "s3-to-dynamodb-import"
}

data "aws_caller_identity" "current" {}