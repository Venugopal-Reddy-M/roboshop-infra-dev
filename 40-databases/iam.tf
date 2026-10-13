#### this is the file for creating IAM role for mysql database to access SSM parameters and secrets manager. This role will be attached to the mysql database instance.
resource "aws_iam_role" "mysql" {
  name = local.mysql_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
    tags = merge(
        {
            Name = local.mysql_role_name
        },
        local.common_tags
    )
}