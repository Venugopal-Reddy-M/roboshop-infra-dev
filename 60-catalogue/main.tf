#### catalogue_instance ####
resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_ids
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh" # Local file path
    destination = "/tmp/bootstrap.sh"    # Destination path on the remote machine
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh catalogue ${var.environment}"
    ]
  }
}
 ## here stop the catalogue instance ##
 ### depends_on is used to execute dependents
resource "aws_ec2_instance_state" "stop_catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped" # Options: running, stopped
  depends_on = [terraform_data.catalogue]
}

### here create the AMI for above instance ####
resource "aws_ami_from_instance" "catalogue_ami" {
  name               = "${var.project}-${var.environment}-catalogue-ami"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [aws_ec2_instance_state.stop_catalogue]

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60 

   health_check {
    #enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = 8080            # Uses the target group port (8080). Can also be a specific port number (e.g., "9000").
    interval            = 10              # Seconds between health checks (5 to 300)
    timeout             = 2               # Seconds to wait for a response (2 to 120)
    healthy_threshold   = 2               # Consecutive successes required to be healthy (2 to 10)
    unhealthy_threshold = 3               # Consecutive failures required to be unhealthy (2 to 10)
    matcher             = "200-299"       # HTTP codes to accept. Supports ranges (e.g., "200,302" or "200-399")
  }
}

resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}"
  image_id = aws_ami_from_instance.catalogue_ami.id

  ## if saw the traffic down, autoscaling terminate the instances.
  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = local.catalogue_sg_id

  update_default_version = true

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}



