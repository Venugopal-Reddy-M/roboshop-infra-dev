module "vpc" {
    source = "git::https://github.com/Venugopal-Reddy-M/terraform-aws-vpc.git?ref=main"
    project = var.project
    environment = var.environment
    is_peering_enabled = true

}

