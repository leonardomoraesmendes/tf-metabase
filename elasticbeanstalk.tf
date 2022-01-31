resource "random_string" "random" {
  length           = 8
  special          = false
  min_upper = 0
}

resource "aws_s3_bucket" "metabase" {
  bucket_prefix = "${var.name}-"
  force_destroy = true
  tags = {
    Name = var.name
  }
}

resource "aws_s3_bucket_object" "metabase" {
  depends_on = [
    null_resource.metabase
  ]
  bucket = aws_s3_bucket.metabase.id
  key    = replace(var.artifact_file, "artifacts/", "")
  source = var.artifact_file
}

resource "aws_elastic_beanstalk_application" "metabase" {
  name = "application-${var.name}"
}

resource "aws_elastic_beanstalk_application_version" "metabase" {
  name        = "${aws_elastic_beanstalk_application.metabase.name}-${var.metabase_version}"
  application = "application-${var.name}"
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.metabase.id
  key         = aws_s3_bucket_object.metabase.id
}



resource "aws_elastic_beanstalk_environment" "metabase" {
  name                = "environment-${var.name}"
  application         = aws_elastic_beanstalk_application.metabase.name
  cname_prefix        = "${var.name}-${random_string.random.result}"
  solution_stack_name = "64bit Amazon Linux 2 v3.4.10 running Docker"

  dynamic "setting" {
    for_each = local.settings
    content {
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }

}