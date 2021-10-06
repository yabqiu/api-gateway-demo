resource "aws_ecr_repository" "apidemo-lambda" {
  name = "apidemo-lambda"
}

output ecr-url {
  value = aws_ecr_repository.apidemo-lambda.repository_url
}
