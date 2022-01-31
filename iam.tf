resource "aws_iam_role" "beanstalk_service" {
  name               = "beanstalk-service"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
  name               = "beanstalk-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "beanstalk-service-user"
  role = aws_iam_role.beanstalk_service.name
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "beanstalk-ec2-user"
  role = aws_iam_role.beanstalk_ec2.name
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
  name       = "elastic-beanstalk-service"
  roles      = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name       = "elastic-beanstalk-service-health"
  roles      = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_worker" {
  name       = "elastic-beanstalk-ec2-worker"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
  name       = "elastic-beanstalk-ec2-web"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_container" {
  name       = "elastic-beanstalk-ec2-container"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_policy_attachment" "ec2-athena" {
  name       = "elastic-beanstalk-ec2-athena"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_iam_policy_attachment" "ec2-glue" {
  name       = "elastic-beanstalk-ec2-glue"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy_attachment" "ec2-s3" {
  name       = "elastic-beanstalk-ec2-s3"
  roles      = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
