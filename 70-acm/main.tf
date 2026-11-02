############# this service is independent of other services, so we can create it first and then use it in other services. #############
# create acm certificate for roboshop domain
resource "aws_acm_certificate" "roboshop_acm_certificate" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
 
 tags = merge(
      {
        Name = "${var.project}-${var.environment}-${var.domain_name}"
      },
      local.common_tags
    )

  lifecycle {
    create_before_destroy = true
  }
}

# create route53 records for certificate validation
resource "aws_route53_record" "roboshop_acm_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.roboshop_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}
# aws
resource "aws_acm_certificate_validation" "roboshop_acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.roboshop_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.roboshop_acm_certificate_validation : record.fqdn]
}
    
