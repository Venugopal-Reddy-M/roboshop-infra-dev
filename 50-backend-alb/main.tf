## backend alb code ##
resource "aws_lb" "backend_alb" {
  name               = "${var.project}-${var.environment}-backend-alb" ##roboshop-dev-backend-alb
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids
   
  ## enable_deletion_protection is set to false, so that we can delete the alb if required.
  ## what it means, we can delete through terraform.
  enable_deletion_protection = false

tags = merge(
    {
        Name = "${var.project}-${var.environment}-backend-alb"
    },
    local.common_tags
  )
}

## backend alb_listener code ##
resource "aws_lb_listener" "backend_alb_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, Backend ALB is working</h1>"
      status_code  = "200"
    }
  }
}

## r53 record for backend alb ##
resource "aws_route53_record" "backend_alb_r53" {
  zone_id = var.zone_id
  ## * is used to create a wildcard record, so that all the subdomains will be pointed to this alb.
  name    = "*.backend_alb-${var.environment}.${var.domain_name}"
  type    = "A"
  
  ### below are load balancer details, which we are using to create the alias record in route53.
  alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
  }
}