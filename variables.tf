variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_session_token" {}

variable key_path { default = "~/.ssh/id_rsa.pub"}
variable "artifact_file" { default = "artifacts/metabase.zip" }
variable "metabase_version" { default = "v0.41.5" }
variable "region" { default = "us-east-1" }
variable "name" { default = "metabase" }
variable "instancetype" { default = "t3a.small"}
variable "asg_min_size" { default = "1" }
variable "asg_max_size" { default = "4" }
variable "elb_timeout" { default = "1200" } #20min

#fill this variables to execute terraform
variable "vpc_id" { default = "vpc-xpto"}
variable "vpc_cidr" { default = "172.31.0.0/16" }
variable "subnet_ids" { 
  type = list
  default = ["subnet-xyzw", "subnet-xpto"]
}

variable "tags" {
  type = map(string)
  default = {
    "Terraform" = "true"
  }
}

locals {
  metabase_source_url = "https://downloads.metabase.com/${var.metabase_version}/metabase-aws-eb.zip"
  settings = [
    {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = var.vpc_id
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(", ", var.subnet_ids)
    },
    {
      namespace = "aws:elasticbeanstalk:application"
      name      = "Application Healthcheck URL"
      value     = "/api/health"
    },
    {
      namespace = "aws:elb:policies"
      name      = "ConnectionSettingIdleTimeout"
      value     = var.elb_timeout
    },
    {
      namespace = "aws:elb:loadbalancer"
      name      = "SecurityGroups"
      value     = aws_security_group.allow_tls.id
    },
    {
      namespace = "aws:elb:listener"
      name      = "InstancePort"
      value     = "80"
    },
    # To enable SSL put the ACM arn here
    # {
    #   namespace = "aws:elb:listener:443"
    #   name      = "SSLCertificateId"
    #   value     = ""
    # },
    # {
    #   namespace = "aws:elb:listener:443"
    #   name      = "ListenerProtocol"
    #   value     = "HTTPS"
    # },
    # {
    #   namespace = "aws:elb:listener:443"
    #   name      = "InstancePort"
    #   value     = "80"
    # },
    # {
    #   namespace = "aws:elb:listener:443"
    #   name      = "ListenerEnabled"
    #   value     = true
    # },
    {
      namespace = "aws:elb:policies"
      name      = "ConnectionSettingIdleTimeout"
      value     = "1200"
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = aws_key_pair.ssh-key.key_name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SSHSourceRestriction"
      value     = "tcp, 22, 22, ${aws_security_group.allow_tls.id}"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "ServiceRole"
      value     = aws_iam_role.beanstalk_service.name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = aws_iam_instance_profile.beanstalk_ec2.name
    },
    {
      namespace = "aws:ec2:instances"
      name      = "InstanceTypes"
      value     = var.instancetype
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = var.asg_min_size
    },
    {
      namespace = "aws:autoscaling:asg"
      name      = "MaxSize"
      value     = var.asg_max_size
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_DBNAME"
      value     = var.name
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_HOST"
      value     = module.rds.db_instance_address
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_PASS"
      value     = random_password.random.result
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_PORT"
      value     = "3306"
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_TYPE"
      value     = "mysql"
    },
    {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "MB_DB_USER"
      value     = var.name
    }
  ]
}