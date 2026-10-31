resource "aws_ssm_parameter" "backend_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/backend_alb_listener_arn"
  type  = "String"
  ### value we get form aws_ld_listener core form main.tf
  value = aws_lb_listener.backend_alb_listener.arn
}