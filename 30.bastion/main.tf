resource "aws_instance" "bastion" {
  ami = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [local.bastion_sg_id]
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  #### this is the user_data script it will terraform directly
  user_data = file("bastion.sh")

  #### rooot block device configuration, its adding 50 GB gp3 volume to the instance####
  #### so that we can install terraform and other tools on the bastion host####

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
    {
        Name ="${var.project}-${var.environment}-bastion"
    },
    local.common_tags
  )
  }
  tags = merge(
    {
        Name ="${var.project}-${var.environment}-bastion"
    },
    local.common_tags
  )
}

resource "aws_iam_role" "bastion" {
  name = "RoboshopDevBastion"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags =  merge(
    {
        Name ="RoboshopDevBastion"
    },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project}-${var.environment}-bastion"
  role = aws_iam_role.bastion.name
}