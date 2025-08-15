#create an ec2 resource with autoscaling group

resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-app-lt"
  image_id      = var.image_id  # Replace with your desired AMI ID
  instance_type = var.instance_type
  key_name      = var.key_name         # Replace with your EC2 Key Pair name
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
   user_data = base64encode(<<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "Hello from EC2 instance!" > /var/www/html/index.html
    EOF
      )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "asg-instance"
    }
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my-app-sg"
  description = "Allow inbound HTTP and SSH"
  vpc_id      = var.vpc_id # Replace with your VPC ID

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict as needed
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg-prod" {
  name                      = "asg-prod"  # The name of your Auto Scaling group
  max_size                  = 5  # Maximum number of instances allowed
  min_size                  = 2  # Minimum number of instances to maintain
  desired_capacity          = 2  # Initial desired number of instances
  vpc_zone_identifier       = var.vpc_zone_identifier # List of subnets
  health_check_type         = "EC2"  # Or "ELB" if using a load balancer
  default_cooldown          = 120 # Cool down period (in seconds) between scaling activities

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"  # Always use the latest version of the launch template
  }

  # Optional:  Ignore desired_capacity changes from outside Terraform for dynamic scaling
  lifecycle {
    ignore_changes = [desired_capacity]
  }

  tag {
        key                 = "Name"
        value               = "asg-prod-instance"
        propagate_at_launch = true
      }
  
}
resource "aws_autoscaling_policy" "cpu_target_tracking_policy" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.asg-prod.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0  # Maintain average CPU utilization at 50%
  }
}
