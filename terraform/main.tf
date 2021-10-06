provider "aws" {
  region = "us-east-1"
}

module "lambda-api-gateway" {
  source = "./lambda-api-gateway"
  ecr = aws_ecr_repository.apidemo-lambda
}
