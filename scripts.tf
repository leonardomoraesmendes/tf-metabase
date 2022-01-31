resource "null_resource" "metabase" {
  provisioner "local-exec" {
    command = "curl -o ${var.artifact_file} ${local.metabase_source_url}"
  }
}
resource "null_resource" "deploy-eb" {
    provisioner "local-exec" {
    command = "aws elasticbeanstalk update-environment --region ${var.region} --environment-name ${aws_elastic_beanstalk_environment.metabase.name} --version-label ${aws_elastic_beanstalk_application_version.metabase.name} "
    environment = {
      AWS_ACCESS_KEY_ID        = var.aws_access_key_id
      AWS_SECRET_ACCESS_KEY    = var.aws_secret_access_key
      AWS_DEFAULT_REGION       = var.region
      AWS_SESSION_TOKEN        = var.aws_session_token
    }
  }
}