### this is we get form the vpc module and its used for creating for security groups(sg) ######
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

