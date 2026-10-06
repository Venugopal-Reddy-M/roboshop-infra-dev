module "sg" {
  source = "../../terraform-sg-module"
  count = length(var.sg_names)
  project     = var.project
  environment = var.environment
  #sg_name     = var.sg_names[count.index]
  sg_name = replace(var.sg_names[count.index],"_","-")
  vpc_id      = local.vpc_id
}