resource "aws_dms_endpoint" "origin" {
  endpoint_id   = var.source_endpoint_id
  endpoint_type = "source"
  engine_name   = "s3"

  s3_settings {
    bucket_folder             = ""
    bucket_name               = aws_s3_bucket.dynamodb_import_bucket.bucket
    compression_type          = "NONE"
    csv_delimiter             = var.csv_delimiter
    csv_row_delimiter         = var.csv_row_delimiter
    external_table_definition = data.template_file.extra_connection_attributes.rendered

    service_access_role_arn = aws_iam_role.dms_vpc_role.arn
  }
}

data "template_file" "extra_connection_attributes" {
  template = file( "files/extra_connection_attributes.json" )
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = var.target_endpoint_id
  endpoint_type = "target"
  engine_name   = "dynamodb"

  service_access_role = aws_iam_role.dms_vpc_role.arn
}

resource "aws_dms_replication_instance" "dynamodb-import-instance" {
  engine_version             = "3.1.3"
  multi_az                   = "false"
  publicly_accessible        = "false"
  replication_instance_class = var.dms_replication_instance_type
  replication_instance_id    = var.replication_instance_id

  depends_on = [ aws_iam_role.dms_vpc_role ]
}

resource "aws_dms_replication_task" "dynamodb-import-task" {
  migration_type            = "full-load"
  replication_instance_arn  = aws_dms_replication_instance.dynamodb-import-instance.replication_instance_arn
  replication_task_id       = var.replication_task_id
  replication_task_settings = data.template_file.replication-task-settings.rendered
  source_endpoint_arn       = aws_dms_endpoint.origin.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  table_mappings            = data.template_file.table-mappings.rendered
}

data "template_file" "table-mappings" {
  template = file( "files/table_mappings.json" )
}

data "template_file" "replication-task-settings" {
  template = file( "files/replication_task_settings.json" )
}

