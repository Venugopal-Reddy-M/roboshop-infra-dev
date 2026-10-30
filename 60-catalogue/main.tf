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
### target-group
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
### launch_template
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}"
  image_id = aws_ami_from_instance.catalogue_ami.id

  ## if saw the traffic down, autoscaling terminate the instances.
  ## auto_scaling saw the less traffic, below attribute execute and terminate instance
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  update_default_version = true
  
  ## tags for volume created by instances
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }
  # tags for launch template
    tags = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    ) 
}
#### auto_scaling ####
resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project}-${var.environment}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  
   launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.private_subnet_ids]

  target_group_arns = [aws_lb_target_group.catalogue.arn]
  
  ### instance_refresh means create new instances and delete old instances ###
    instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  # tag {
  #   key                 = "Name"
  #   value               = "${var.project}-${var.environment}-catalogue"
  #   propagate_at_launch = true
  # }

  dynamic "tag" {
    for_each = merge(
      {
        Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
    content {
      key   = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
  
  ## with in 15min autoscaling  should successful
  timeouts {
    delete = "15m"
  }

}

### autoscaling policy
resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${var.project}-${var.environment}-catalogue"
  # scaling_adjustment     = 4
  # adjustment_type        = "ChangeInCapacity"
  # cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"

  ### target_tracking_configuration means track the CPU utilization 
   target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    ### target_value means CPU utilization 
    target_value = 70.0
  }
}
## listener for rule
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
}



resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  
  depends_on = [aws_autoscaling_policy.catalogue]
  
  ## its executes in bastion
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids {aws_instance.catalogue.id}"
  }
}



