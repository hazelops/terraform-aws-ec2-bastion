# TODO: install Fail2ban
resource "aws_security_group" "this" {
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

  tags = merge({
    Name = "${var.env}-${var.name}"
  }, var.tags)
}

# TODO: This needs to become an autoscale of one instance
resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  key_name               = var.ec2_key_pair_name
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = concat(var.ext_security_groups, [
    aws_security_group.this.id
  ])
  subnet_id                   = length(var.public_subnets) > 0 ? var.public_subnets[0] : var.private_subnets[0]
  associate_public_ip_address = length(var.public_subnets) > 0 ? true : false
  tags                        = merge({
    Name = "${var.env}-${var.name}"
  }, var.tags)
}
