resource "aws_security_group" "this" {
  count  = var.manage_security_group ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.env}-${var.name}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.allowed_cidr_blocks
  }

  tags = {
    Name = "${var.env}-${var.name}"
  }

}

resource "aws_instance" "this" {
  count                = var.asg_enabled ? 0 : 1
  ami                  = length(var.instance_ami) > 0 ? var.instance_ami : data.aws_ami.this.id
  key_name             = var.ec2_key_pair_name
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.this[count.index].name
  vpc_security_group_ids = var.manage_security_group ? concat(var.security_groups, [
    aws_security_group.this[count.index].id
  ]) : var.security_groups
  subnet_id                   = length(var.public_subnets) > 0 ? var.public_subnets[0] : var.private_subnets[0]
  associate_public_ip_address = length(var.public_subnets) > 0 ? true : false
  tags = merge({
    Name = "${var.env}-${var.name}"
  }, var.tags)
}

module "asg_bastion" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~>6.10"

  count = var.asg_enabled ? 1 : 0

  # Autoscaling group
  name = "${var.env}-${var.name}"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnets

  # Launch template
  launch_template_name        = "${var.env}-${var.name}"
  launch_template_description = "SSM Bastion Host"
  update_default_version      = true

  image_id      = length(var.instance_ami) > 0 ? var.instance_ami : data.aws_ami.this.id
  instance_type = var.instance_type
  #   ebs_optimized     = true
  #   enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = var.manage_iam_instance_profile
  iam_role_name               = "${var.env}-${var.name}-SSM"
  iam_role_description        = "${var.env} Bastion SSM Access"

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    },
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  cpu_options = {
    core_count       = var.asg_cpu_core_count
    threads_per_core = var.asg_cpu_threads_per_core
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 90
    }
  }

  instance_market_options = {
    market_type = "spot"
    #     spot_options = {
    #       block_duration_minutes = 60
    #     }
  }

  # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
  # best practices
  # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = concat(var.security_groups, [aws_security_group.this[count.index].id])
    }
  ]

  placement = {
    availability_zone = data.aws_availability_zones.available.names[0] # Use first available AZ
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = merge(var.tags, { propagate_at_launch = true })
    }
  ]

}
