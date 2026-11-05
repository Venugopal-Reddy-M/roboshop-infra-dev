
module "component" {
     for_each = var.components
     source = "git::https://github.com/Venugopal-Reddy-M/terraform-roboshop-component-module.git"
     component = each.key
     rule_priority = each.value.rule_priority

  
}