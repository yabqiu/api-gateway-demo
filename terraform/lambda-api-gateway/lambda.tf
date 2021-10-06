resource "aws_lambda_function" "apidemo-lambda" {
  function_name = "apidemo-lambda"
  description = "Demo API Gateway with Lambda"
  timeout       = 300
  role          = aws_iam_role.apidemo_lambda_role.arn
  package_type  = "Image"
  image_uri     = "${var.ecr.repository_url}@${data.aws_ecr_image.lambda_image.id}"
}

# this docker image must be present, or else can't create the Lambda function
data aws_ecr_image lambda_image {
  repository_name = var.ecr.name
  image_tag       = var.image-tag
}

variable image-tag {
  default = "1.0.0"
}

variable "ecr" {
}
