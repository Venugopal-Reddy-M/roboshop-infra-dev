 ### store the vpc_id in ssm parameter ###
 resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
  
}

##### Store the Subnet ID in SSM Parameter Store #####
resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "/${var.project}/${var.environment}/public_subnet_ids"
  description = "The ID of the application ${var.project}-${var.environment}public subnet"
  type        = "StringList"
  value = join(",", module.vpc.public_subnet_ids)
}


##### Store the Subnet ID in SSM Parameter Store #####
resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "/${var.project}/${var.environment}/private_subnet_ids"
  description = "The ID of the application ${var.project}-${var.environment}-private subnet"
  type        = "StringList"
  value = join(",", module.vpc.private_subnet_ids)
}

##### Store the Subnet ID in SSM Parameter Store #####
resource "aws_ssm_parameter" "database_subnet_ids" {
  name        = "/${var.project}/${var.environment}/database_subnet_ids"
  description = "The ID of the application ${var.project}-${var.environment}-database subnet"
  type        = "StringList"
  value = join(",", module.vpc.database_subnet_ids)
}