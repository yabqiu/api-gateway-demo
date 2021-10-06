resource "aws_iam_role" "apidemo_lambda_role" {
  name               = "apidemo_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment attach-lambda_basic_access_execution_role {
  role       = aws_iam_role.apidemo_lambda_role.id
  policy_arn = data.aws_iam_policy.lambdaBasicExecutionRole.arn
}


data "aws_iam_policy" "lambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

