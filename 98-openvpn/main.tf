resource "aws_instance" "bastion" {
  ami = local.ami_id
  instance_type = "t3.small"
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [local.openvpn_sg_id]
  

  #### this is the user_data script it will terraform directly
  user_data = file("vpn.sh")

  tags = merge(
    {
        Name ="${var.project}-${var.environment}-bastion"
    },
    local.common_tags
  )
}