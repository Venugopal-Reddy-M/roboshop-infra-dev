##### bastion accepting connection from internet ######
resource "aws_security_group_rule" "bastion_internet" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = [local.my_ip]
    security_group_id = local.bastion_sg_id  # this is sg_id of bastion.
}

# OUTBOUND - Bastion can access anywhere
resource "aws_security_group_rule" "bastion_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.bastion_sg_id
}

##### mongodb accepting connection from bastion ######
resource "aws_security_group_rule" "mongodb_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.mongodb_sg_id
}

##### mongodb accepting connection from catalogue ######
resource "aws_security_group_rule" "mongodb_catalogue" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id = local.mongodb_sg_id
}

##### mongodb accepting connection from user ######
resource "aws_security_group_rule" "mongodb_user" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id = local.mongodb_sg_id
}