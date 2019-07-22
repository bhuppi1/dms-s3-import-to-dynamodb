resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = data.aws_iam_policy_document.dms_vpc_role_policy.json
}

data "aws_iam_policy_document" "dms_vpc_role_policy" {
  statement {
    effect  = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type        = "Service"
      identifiers = [ "dms.amazonaws.com" ]
    }
  }
}

resource "aws_iam_policy_attachment" "dms_vpc_role_s3" {
  name       = "dms_vpc_role_s3"
  roles      = [ aws_iam_role.dms_vpc_role.name ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "dms_vpc_role_dynamodb" {
  name       = "dms_vpc_role_dynamodb"
  roles      = [ aws_iam_role.dms_vpc_role.name ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "dms_vpc_role_dms" {
  name       = "dms_vpc_role_dms"
  roles      = [ aws_iam_role.dms_vpc_role.name ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  name               = "dms-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.dms_vpc_role_policy.json
}

resource "aws_iam_policy_attachment" "dms-cloudwatch-role-dms" {
  name       = "dms-cloudwatch-role-dms"
  roles      = [ aws_iam_role.dms_cloudwatch_logs_role.name ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

data "aws_iam_policy_document" "import_bucket_policy" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [ "logs.eu-west-1.amazonaws.com" ]
    }
    actions   = [ "s3:GetBucketAcl" ]
    resources = [
      "arn:aws:s3:::dynamodb-import-bucket"
    ]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [ "logs.eu-west-1.amazonaws.com" ]
    }
    actions   = [ "s3:PutObject" ]
    resources = [
      "arn:aws:s3:::dynamodb-import-bucket/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}