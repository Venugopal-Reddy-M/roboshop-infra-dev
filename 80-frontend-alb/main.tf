## frontend alb code ##
resource "aws_lb" "frontend_alb" {
  name               = "${var.project}-${var.environment}-frontend-alb" ##roboshop-dev-frontend-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids
   
  ## enable_deletion_protection is set to false, so that we can delete the alb if required.
  ## what it means, we can delete through terraform.
  enable_deletion_protection = false

tags = merge(
    {
        Name = "${var.project}-${var.environment}-frontend-alb"
    },
    local.common_tags
  )
}

## frontend alb_listener code ##
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = local.frontend_alb_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, Frontend ALB is working</h1>"
      status_code  = "200"
    }
  }
}

## r53 record for frontend alb ##
resource "aws_route53_record" "frontend_alb_r53" {
  zone_id = var.zone_id
  ## * is used to create a wildcard record, so that all the subdomains will be pointed to this alb.
  name    = "*.frontend-alb-${var.environment}.${var.domain_name}"  # catalogue.frontend-alb-dev.solohunting.online
  type    = "A"
  
  ### below are load balancer details, which we are using to create the alias record in route53.
  alias {
    name                   = aws_lb.frontend_alb.dns_name
    zone_id                = aws_lb.frontend_alb.zone_id
    evaluate_target_health = true
  }
} 