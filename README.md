# AWS Terraform Module for EC2 Bastion with SSM
[![e2e tests](https://github.com/hazelops/terraform-aws-ec2-bastion/actions/workflows/run.e2e-tests.yml/badge.svg)](https://github.com/hazelops/terraform-aws-ec2-bastion/actions/workflows/run.e2e-tests.yml)
This module creates a basic EC2 bastion host (Single or ASG) in a private subnet of a VPC and connects it to AWS Systems Manager.
This Bastion host can be used to access other private resources in the VPC via SSM.
There is no need to expose it via a public IP for SSH access since we're using SSM as a first transport.


## Prerequisites
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (1.16.220 or more recent)
- [AWS System Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) (version 1.1.26.0 or more recent) 
   
## Usage Example
Below is a simple usage example of the module. 
```terraform
module "bastion" {
    source    = "hazelops/ec2-bastion/aws"
    version   = "~> 5.0"
    
    env               = "dev"
    vpc_id            = "vpc-1234567890"
    private_subnets   = ["subnet-1234567890", "subnet-1234567891"]
    ec2_key_pair_name = "my-key-pair"
    tags = {
      # Optionally add atun.io-compatible configuration here for Tunnel Discovery 
      "atun.io/env" = "dev"
      "atun.io/version" = "1"      
      
      ## Forwarding RDS to a local port 15432 
      "atun.io/host/${module.rds_api.cluster_endpoint}" = jsonencode({
        "proto" = "ssm"
        "local" =  15432
        "remote" = module.rds_api.api.cluster_port
      }),
      
      ## Forwarding Redis to a local port 16379
      "atun.io/host/${module.redis_api.cache_nodes.0.address}" = jsonencode({
        "proto" = "ssm"
        "local" =  16379
        "remote" = module.redis_api.cache_nodes.0.port
      }),
      
      ## Forwarding OpenSearch to a local port 10443
      "atun.io/host/${module.opensearch_api.endpoint}" = jsonencode({
        "proto" = "ssm"
        "local" =  10443
        "remote" = 443
      }),
    }
}

### Modules Omitted ###
module "rds_api" {
  source = "terraform-aws-modules/rds/aws"
  # Omitted for brevity
}

module "redis_api" {
  source = "terraform-aws-modules/elasticache/aws"
  # Omitted for brevity
}

module "opensearch_api" {
  source = "terraform-aws-modules/opensearch/aws"
  # Omitted for brevity
}
#######################
```


### AWS SSM AWS-StartPortForwardingSessionToRemoteHost Usage
This is a simple example without using `atun.io` discovery tags.
This option is limited to a single host and port.
```bash
aws ssm start-session \
--target i-xxxxxxxxxxxx \
--document-name AWS-StartPortForwardingSessionToRemoteHost \
--parameters ' \
{"host":["mydb.example.us-east-2.rds.amazonaws.com"],"portNumber":["5432"], "localPortNumber":["15432"]}'
```

### AWS SSM With atun.io Discovery Tags
Get [atun](https://github.com/automationd/atun)
```bash
atun up
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg_bastion"></a> [asg\_bastion](#module\_asg\_bastion) | terraform-aws-modules/autoscaling/aws | ~>9.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of network subnets that are allowed. According to PCI-DSS, CIS AWS and SOC2 providing a default wide-open CIDR is not secure. | `list(string)` | n/a | yes |
| <a name="input_asg_cpu_core_count"></a> [asg\_cpu\_core\_count](#input\_asg\_cpu\_core\_count) | Number of CPU cores to use for autoscaling group | `number` | `1` | no |
| <a name="input_asg_cpu_threads_per_core"></a> [asg\_cpu\_threads\_per\_core](#input\_asg\_cpu\_threads\_per\_core) | Number of threads per core to use for autoscaling group | `number` | `1` | no |
| <a name="input_asg_enabled"></a> [asg\_enabled](#input\_asg\_enabled) | Enable autoscaling group for bastion host. If enabled, the bastion host will be created as an autoscaling group | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for the bastion host | `number` | `20` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for the bastion host | `string` | `"gp3"` | no |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | EC2 Key Pair Name that the bastion host would be created with | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name, for example `dev` | `string` | n/a | yes |
| <a name="input_external_ebs_volume_id"></a> [external\_ebs\_volume\_id](#input\_external\_ebs\_volume\_id) | External EBS volume ID to attach to the bastion host | `string` | `""` | no |
| <a name="input_instance_ami"></a> [instance\_ami](#input\_instance\_ami) | AMI ID override for the bastion host. Keep in mind, this module config is targeting Amazon Linux 2023) | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for bastion host | `string` | `"t4g.nano"` | no |
| <a name="input_manage_iam_instance_profile"></a> [manage\_iam\_instance\_profile](#input\_manage\_iam\_instance\_profile) | Whether to manage the IAM role for the bastion host | `bool` | `true` | no |
| <a name="input_manage_security_group"></a> [manage\_security\_group](#input\_manage\_security\_group) | Whether to manage the security group for the bastion host | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the bastion host | `string` | `"bastion"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public subnets (if set, private subnets are ignored) | `list(string)` | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Additional security groups to add to bastion host | `list(any)` | `[]` | no |
| <a name="input_ssm_role"></a> [ssm\_role](#input\_ssm\_role) | SSM role to attach to the bastion host | `string` | `"arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for the resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the bastion host will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | The ID of the security group |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags for the bastion host |
<!-- END_TF_DOCS -->
