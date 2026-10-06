data "http" "my_public_ip_v4" {
  url = "https://ifconfig.me/ip"
}

#### this is my local/pc public ip address #########
output "public_ip" {
  value = chomp(data.http.my_public_ip_v4.response_body)
}

data "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project}/${var.environment}/bastion_sg_id"
}

data "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project}/${var.environment}/mongodb_sg_id"
}

data "aws_ssm_parameter" "catalogue_sg_id" {
  name = "/${var.project}/${var.environment}/catalogue_sg_id"
}

data "aws_ssm_parameter" "user_sg_id" {
  name = "/${var.project}/${var.environment}/user_sg_id"
}