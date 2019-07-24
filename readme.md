# Massive import/export data from S3 to DynamoDB

This repository contains a terraform inventory **example** that can be used to import or export a huge data amount (in csv files) from S3 to DynamoDB using AWS Database Migration Service (DMS).

## Requirements

*  Terraform version >= 0.12.0
*  AWS Account
*  Valid IAM credentials with enough privileges (IAM, DynamoDB, S3 and DMS)

## Usage

Once you have setted your valid AWS IAM credentials you have to perform the following actions

```bash
terraform init
```

There is a [bug in terraform aws provider](https://github.com/hashicorp/terraform/issues/20346) that make a the first apply fail whe trying to create the replication instance, so you have to perform, at least, two consecutive apply actions:


```bash
terraform apply
```

This will perform the following actions:

```bash
  # aws_dms_endpoint.origin will be created
  + resource "aws_dms_endpoint" "origin" {
      ...
      + endpoint_id                 = "s3-origin"
      + endpoint_type               = "source"
      + engine_name                 = "s3"
      ...

      + s3_settings {
          + bucket_name               = "dynamodb-import-bucket"
          + compression_type          = "NONE"
          + csv_delimiter             = "|"
          + csv_row_delimiter         = "\\n"
          + external_table_definition = jsonencode(
                {
                  + TableCount = "1"
                  + Tables     = [
                      + {
                          + TableColumns      = [
                              + {
                                  + ColumnIsPk     = "true"
                                  + ColumnLength   = "25"
                                  + ColumnName     = "id"
                                  + ColumnNullable = "false"
                                  + ColumnType     = "STRING"
                                },
                              + {
                                  + ColumnLength   = "20"
                                  + ColumnName     = "name_value"
                                  + ColumnNullable = "false"
                                  + ColumnType     = "STRING"
                                },
                            ]
                          + TableColumnsTotal = "2"
                          + TableName         = "test"
                          + TableOwner        = "import"
                          + TablePath         = "import/test/"
                        },
                    ]
                }
            )
          + service_access_role_arn   = (known after apply)
        }
    }

  # aws_dms_endpoint.target will be created
  + resource "aws_dms_endpoint" "target" {
      ...
      + endpoint_id                 = "dynamodb-target"
      + endpoint_type               = "target"
      + engine_name                 = "dynamodb"
      ...
    }

  # aws_dms_replication_instance.dynamodb-import-instance will be created
  + resource "aws_dms_replication_instance" "dynamodb-import-instance" {
      ...
      + engine_version                   = "3.1.3"
      ...
      + replication_instance_class       = "dms.t2.small"
      ...
    }

  # aws_dms_replication_task.dynamodb-import-task will be created
  + resource "aws_dms_replication_task" "dynamodb-import-task" {
      ...
      + replication_task_id       = "s3-to-dynamodb-import"
      + replication_task_settings = jsonencode(
            {
              ...
              + Logging                           = {
                  + CloudWatchLogGroup  = "dms-tasks-replication-instance"
                  + CloudWatchLogStream = "dms-task-MW5DOHLW3RKO7S4KVR3RGJB4NE"
                  + EnableLogging       = true
                  ...
            }
        )
      ...
      + table_mappings            = jsonencode(
            {
              + rules = [
                  + {
                      + object-locator = {
                          + schema-name = "import"
                          + table-name  = "test"
                        }
                      + rule-action    = "include"
                      + rule-id        = "1"
                      + rule-name      = "1"
                      + rule-type      = "selection"
                    },
                  + {
                      + mapping-parameters = {
                          + attribute-mappings = [
                              + {
                                  + attribute-sub-type    = "string"
                                  + attribute-type        = "scalar"
                                  + target-attribute-name = "id"
                                  + value                 = "${id}"
                                },
                              + {
                                  + attribute-sub-type    = "string"
                                  + attribute-type        = "scalar"
                                  + target-attribute-name = "name_value"
                                  + value                 = "${name_value}"
                                },
                            ]
                          + partition-key-name = "id"
                        }
                      + object-locator     = {
                          + schema-name = "import"
                          + table-name  = "test"
                        }
                      + rule-action        = "map-record-to-record"
                      + rule-id            = "2"
                      + rule-name          = "2"
                      + rule-type          = "object-mapping"
                      + target-table-name  = "test"
                    },
                ]
            }
        )
    }

  # aws_dynamodb_table.import_table will be created
  + resource "aws_dynamodb_table" "import_table" {
      ...
      + name             = "test"
      ...

      + attribute {
          + name = "id"
          + type = "S"
        }
    }

  # aws_iam_policy_attachment.dms-cloudwatch-role-dms will be created
  + resource "aws_iam_policy_attachment" "dms-cloudwatch-role-dms" {
      ...
      + name       = "dms-cloudwatch-role-dms"
      + policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
      + roles      = [
          + "dms-cloudwatch-logs-role",
        ]
    }

  # aws_iam_policy_attachment.dms_vpc_role_dms will be created
  + resource "aws_iam_policy_attachment" "dms_vpc_role_dms" {
      ...
      + name       = "dms_vpc_role_dms"
      + policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
      + roles      = [
          + "dms-vpc-role",
        ]
    }

  # aws_iam_policy_attachment.dms_vpc_role_dynamodb will be created
  + resource "aws_iam_policy_attachment" "dms_vpc_role_dynamodb" {
      ...
      + name       = "dms_vpc_role_dynamodb"
      + policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
      + roles      = [
          + "dms-vpc-role",
        ]
    }

  # aws_iam_policy_attachment.dms_vpc_role_s3 will be created
  + resource "aws_iam_policy_attachment" "dms_vpc_role_s3" {
      ...
      + name       = "dms_vpc_role_s3"
      + policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      + roles      = [
          + "dms-vpc-role",
        ]
    }

  # aws_iam_role.dms_cloudwatch_logs_role will be created
  + resource "aws_iam_role" "dms_cloudwatch_logs_role" {
      ...
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "dms.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      ...
      + name                  = "dms-cloudwatch-logs-role"
      ...
    }

  # aws_iam_role.dms_vpc_role will be created
  + resource "aws_iam_role" "dms_vpc_role" {
      ...
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "dms.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      ...
      + name                  = "dms-vpc-role"
      ...
    }

  # aws_s3_bucket.dynamodb_import_bucket will be created
  + resource "aws_s3_bucket" "dynamodb_import_bucket" {
      ...
      + bucket                      = "dynamodb-import-bucket"
      ...
    }

  # aws_s3_bucket_policy.dynamodb_import_bucket will be created
  + resource "aws_s3_bucket_policy" "dynamodb_import_bucket" {
      ...
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:GetBucketAcl"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "logs.eu-west-1.amazonaws.com"
                        }
                      + Resource  = "arn:aws:s3:::dynamodb-import-bucket"
                      + Sid       = ""
                    },
                  + {
                      + Action    = "s3:PutObject"
                      + Condition = {
                          + StringEquals = {
                              + s3:x-amz-acl = "bucket-owner-full-control"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "logs.eu-west-1.amazonaws.com"
                        }
                      + Resource  = "arn:aws:s3:::dynamodb-import-bucket/*"
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

Plan: 13 to add, 0 to change, 0 to destroy.
```

A total of 13 resources will be added with this terraform inventory. I've removed from this excrept the not so important attributtes in order to highlight the important ones.

The most important ones are:

### aws_dms_endpoint.origin.s3_settings.bucket_name

The name of the bucket where csv files will be placed to import.

### aws_dms_endpoint.origin.s3_settings.external_table_definition

This is a json type attribute containing the origin S3 "table" model definition.

Tables.TableName, Tables.TableOwner and Tables.TablePath attributes, indicates a mandatory path inside the bucket where csv files must be placed in order to use DMS.

### aws_dms_replication_instance.dynamodb-import-instance.replication_instance_class

This attribute indicates the replication instance size.

Take into account that this size is not only a CPU and memory concern for the data to be processed, it also represents network throughput. The bigger the instance is, the better network throughput.

### aws_dms_replication_task.dynamodb-import-task.replication_task_settings

This is a huge json attribute that contains a lot of advanced settigns for the task. If not specified, terraform will place a basic one, but if you want the task to send logs to cloudwatchlogs, in addition to the right IAM permissions, you have specify the CloudWatchLogGroup and CloudWatchLogStream.

The CloudWatchLogStream value only can be retrieved once you have created the infrastructure for the first time, so you will have to modify this value and perform another terraform apply. You can retrieve this value from cloudwatch logs console or using the aws cli.

### aws_dms_replication_task.dynamodb-import-task.table_mappings

Another json attribute that contains, how source previously defined columns will be mapped to the **target DynamoDB table**.

### aws_iam_role.dms_vpc_role.name

This role is a "expected fixed value" for DMS, so the name of the role must be exactly this: "**dms-vpc-role**" (without double quotes).

### aws_iam_role.dms_cloudwatch_logs_role.name

Here you have the same consideration that the above one, the name of the role must be exactly: "**dms-cloudwatch-logs-role**".

## References

*  [Using Amazon S3 as a Source for AWS DMS](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.S3.html)
*  [Using an Amazon DynamoDB Database as a Target for AWS Database Migration Service](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Target.DynamoDB.html)
*  [Migrate Delimited Files from Amazon S3 to an Amazon DynamoDB NoSQL Table Using AWS Database Migration Service and AWS CloudFormation](https://aws.amazon.com/es/blogs/database/migrate-delimited-files-from-amazon-s3-to-an-amazon-dynamodb-nosql-table-using-aws-database-migration-service-and-aws-cloudformation/)