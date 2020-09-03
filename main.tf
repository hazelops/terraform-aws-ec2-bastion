# TODO: install Fail2ban
resource "aws_security_group" "this" {
  name   = "${var.env}-bastion"
  vpc_id = var.vpc_id

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
    Terraform = "true"
    Env       = var.env
    Name      = "${var.env}-bastion"
  }
}

# TODO: This needs to become an autoscale of one instance
resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  key_name             = var.ec2_key_pair_name
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids = concat(var.ext_security_groups, [
    aws_security_group.this.id
  ])
  subnet_id                   = var.private_subnets[0]
  associate_public_ip_address = false

  tags = {
    Terraform = "true"
    Env       = var.env
    Name      = local.name
  }
}
