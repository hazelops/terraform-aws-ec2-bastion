locals {
  name = "${var.env}-bastion"
  ssh_config = concat([
    "Host ${aws_route53_record.this.name}",
    "User ubuntu",
    "IdentityFile ~/.ssh/id_rsa",
  ],var.ssh_forward_rules)
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# TODO: This needs to become an autoscale of one instance
resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  key_name                    = var.ec2_key_pair_name
  instance_type               = var.instance_type

  vpc_security_group_ids = concat(var.security_groups, [
    aws_security_group.this.id
  ])
  subnet_id = var.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Env = var.env
    Name = local.name
  }
}

data "aws_route53_zone" "this" {
  zone_id = var.zone_id
  private_zone = true
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
//  name =  "${var.name}.${var.env}.${var.root_domain_name}"
  name = "${var.name}.${data.aws_route53_zone.this.name}"
  type = "A"
  ttl = "900"
  records = [aws_instance.this.public_ip]
}

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
    Terraform   = "true"
    Env = var.env
    Name = "${var.env}-bastion"
  }

  lifecycle {
    create_before_destroy = true
  }
}

