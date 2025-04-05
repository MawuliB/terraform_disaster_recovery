# IAM Role for the Lambda function
resource "aws_iam_role" "failover_lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Lambda to manage Route 53, EC2, and RDS
resource "aws_iam_policy" "failover_lambda_policy" {
  name = "${var.lambda_role_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        Resource = var.route53_zone_arn
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:StartInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:StartDBInstance",
          "rds:DescribeDBInstances",
          "rds:PromoteReadReplica",
          "rds:DescribeDBLogFiles"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "failover_lambda_role_attach" {
  role       = aws_iam_role.failover_lambda_role.name
  policy_arn = aws_iam_policy.failover_lambda_policy.arn
}

# Lambda function for failover automation
resource "aws_lambda_function" "failover_lambda" {
  function_name = var.lambda_function_name
  handler       = "failover.handler"
  runtime       = var.lambda_runtime
  role          = aws_iam_role.failover_lambda_role.arn
  timeout       = 600  # 10 minutes
  

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = var.lambda_environment_variables
  }
}

resource "aws_cloudwatch_log_group" "failover_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days

  tags              = var.tags
}
