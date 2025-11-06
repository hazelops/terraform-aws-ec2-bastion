module "bastion" {
  source            = "../../"
  name              = "${var.env}-bastion"
  env               = var.env
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  ec2_key_pair_name = var.ec2_key_pair_name
  allowed_cidr_blocks = ["0.0.0.0/0"]
  asg_enabled = false
  tags = {
    # The following tags will be used by tunnel clients to discover the bastion host and setup port forwarding.
    "atun.io/env"                                                        = var.env
    "atun.io/version"                                                    = "1"
    "atun.io/host/${module.rds.cluster_endpoint}" = jsonencode({
      "proto"  = "ssm"
      "local"  = 15432
      "remote" = module.rds.cluster_port
    }),
    "atun.io/host/${module.redis.serverless_cache_endpoint[0].address}" = jsonencode({
      "proto"  = "ssm"
      "local"  = 16379
      "remote" = module.redis.serverless_cache_endpoint[0].port
    }),
  }
}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.env}-vpc"
  cidr = "10.1.0.0/16"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
  public_subnets = [
    "10.1.10.0/23",
    "10.1.12.0/23"
  ]

  private_subnets = [
    "10.1.20.0/23",
    "10.1.22.0/23"
  ]

  manage_default_network_acl = true
  default_network_acl_name   = "${var.env}-${var.namespace}"
  manage_default_security_group = true

}


data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.12"
}

# # RDS as per https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/v9.11.0/examples/serverless/main.tf#L150-L197
module "rds" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.11"

  name              = "aurora-postgresql"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_version    = data.aws_rds_engine_version.postgresql.version
  engine_mode       = "provisioned"
  master_username   = "demo"

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  create_db_subnet_group = true
  skip_final_snapshot = true
  subnets = module.vpc.private_subnets
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  # Serverless v1 clusters do not support managed master user password
  manage_master_user_password = false
  master_password             = "demo-password-0000"

  monitoring_interval = 60

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 2
    seconds_until_auto_pause = 300
    seconds_before_timeout   = 600
    timeout_action           = "ForceApplyCapacityChange"
  }
}

# Redis Serverless As per https://github.com/terraform-aws-modules/terraform-aws-elasticache/blob/master/examples/serverless-cache/main.tf#L21
module "redis" {
  source = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"
  version = "~> 1.4"

  engine     = "redis"
  cache_name = "demo-redis"

  cache_usage_limits = {
    data_storage = {
      maximum = 1
    }
    ecpu_per_second = {
      maximum = 1000
    }
  }

  daily_snapshot_time  = "22:00"
  description          = "demo valkey serverless cluster"

  major_engine_version = "7"
  security_group_ids   = [module.vpc.default_security_group_id]

  snapshot_retention_limit = 7
  subnet_ids               = module.vpc.private_subnets
}

output "tags" {
  value = jsonencode(module.bastion.tags)
}
