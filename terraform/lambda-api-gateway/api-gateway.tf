resource "aws_api_gateway_rest_api" "demo-gateway-api" {
  name = "demoapi"
  api_key_source = "HEADER"
  description = "Define REST APIs for demo"
}

resource "aws_api_gateway_api_key" "demoapi-apikey" {
  name = "demoapi-key"
}

resource "aws_api_gateway_resource" "job_resource" {
  rest_api_id = local.rest_api.id
  parent_id   = local.rest_api.root_resource_id
  path_part   = "jobs"
}

resource "aws_api_gateway_resource" "jobid_resource" {
  parent_id   = aws_api_gateway_resource.job_resource.id
  path_part   = "{jobId}"
  rest_api_id = local.rest_api.id
}

resource "aws_api_gateway_method" "post_job" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.job_resource.id
  rest_api_id   = local.rest_api.id
  api_key_required = true
}

resource "aws_api_gateway_method" get_job_status {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.jobid_resource.id
  rest_api_id   = local.rest_api.id
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "method_response" {
  count = length(local.resource_methods)
  rest_api_id = local.rest_api.id
  resource_id = local.resource_methods[count.index].resource_id
  http_method = local.resource_methods[count.index].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  count = length(local.resource_methods)
  rest_api_id = local.rest_api.id
  resource_id = local.resource_methods[count.index].resource_id
  http_method = local.resource_methods[count.index].http_method
  status_code = aws_api_gateway_method_response.method_response.*[count.index].status_code

  response_templates = {
    "application/json" = ""
  }
}

resource aws_api_gateway_integration integration {
  count = length(local.resource_methods)
  rest_api_id = local.rest_api.id
  resource_id = local.resource_methods[count.index].resource_id
  http_method = local.resource_methods[count.index].http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.apidemo-lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "latest" {
  rest_api_id = local.rest_api.id
  stage_name = "stg"
  description = "Deploy driveapi to staging"
}

resource "aws_api_gateway_usage_plan" "demoapi_usage_plan" {
  name = "demoapi-limit-access"

  api_stages {
    api_id = local.rest_api.id
    stage  = "stg"
  }
  depends_on = [
    aws_api_gateway_deployment.latest
  ]
}

resource "aws_api_gateway_usage_plan_key" "plan_2_key" {
  key_id        = aws_api_gateway_api_key.demoapi-apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.demoapi_usage_plan.id
}

resource "aws_lambda_permission" "allow_api_gatewall" {
  count = length(local.api_path_levels)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.apidemo-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${local.rest_api.execution_arn}/${local.api_path_levels[count.index]}"
}

locals {
  api_path_levels = [
    "*/${aws_api_gateway_method.get_job_status.http_method}${aws_api_gateway_resource.jobid_resource.path}",
    "*/${aws_api_gateway_method.post_job.http_method}${aws_api_gateway_resource.job_resource.path}"
  ]

  rest_api = aws_api_gateway_rest_api.demo-gateway-api

  resource_methods = [
    aws_api_gateway_method.get_job_status,
    aws_api_gateway_method.post_job
  ]
}

output "name" {
  value = aws_api_gateway_integration.integration 
}