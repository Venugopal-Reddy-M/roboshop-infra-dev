locals {
  common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }

    cachingDisabled = data.aws_cloudfront_cache_policy.cache_disabled.id
    cachingOptimized = data.aws_cloudfront_cache_policy.cache_optimized.id

    acm_certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value
}