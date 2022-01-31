resource "random_password" "random" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "password" {
  name  = "rds-${var.name}"
  type  = "SecureString"
  value = random_password.random.result
}
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "rds-${var.name}"

  engine                = "mysql"
  engine_version        = "8.0.20"
  family                = "mysql8.0" # DB parameter group
  major_engine_version  = "8.0"      # DB option group
  instance_class        = "db.t3.small"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  name     = var.name
  username = var.name
  password = random_password.random.result
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  subnet_ids             = var.subnet_ids

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true


  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

}