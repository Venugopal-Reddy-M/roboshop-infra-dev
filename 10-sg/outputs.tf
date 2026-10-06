# output "sg_id" {
#   value = module.sg[*].sg_id
# }

### it gives the sg_names with sg_ids ####
output "sg_ids" {
  value = {
    for i, sg in module.sg :
    var.sg_names[i] => sg.sg_id
  }
}