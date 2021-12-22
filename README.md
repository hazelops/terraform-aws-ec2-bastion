# AWS Terraform Module EC2 Bastion over SSM v2.0
Module creates ec2 bastion host in private subnet (without Public IP-address) of VPC and connects it to System Manager and copy your ssh public key to .ssh/authorized_keys on the bastion ec2. 
Bastion host can be controlled by Session Manager documents.

## Security & Compliance [<img src="https://cloudposse.com/wp-content/uploads/2020/11/bridgecrew.svg" width="250" align="right" />](https://bridgecrew.io/)

Security scanning is graciously provided by Bridgecrew.

| Benchmark | Description |
|--------|---------------|
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=INFRASTRUCTURE+SECURITY) | Infrastructure Security Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+AWS+V1.2) | Center for Internet Security, AWS V1.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_azure)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+AZURE+V1.1) | Center for Internet Security, AZURE V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/pci)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=PCI-DSS+V3.2) | Payment Card Industry Data Security Standards V3.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/nist)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=NIST-800-53) | National Institute of Standards and Technology Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/iso)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=ISO27001) | Information Security Management System, ISO/IEC 27001 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=SOC2) | Service Organization Control 2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_gcp)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+GCP+V1.1) | Center for Internet Security, GCP Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=HIPAA) | Health Insurance Portability and Accountability Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/pci_dss_v321)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=PCI-DSS+V3.2.1) | PCI-DSS V3.2.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/fedramp_moderate)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=FEDRAMP+%28MODERATE%29) | FEDRAMP (MODERATE) Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_kubernetes)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+KUBERNETES+V1.5) | Center for Internet Security, KUBERNETES V1.5 Compliance  |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_aws_13)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+AWS+V1.3) | Center for Internet Security, AWS V1.3 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_azure_13)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+AZURE+V1.3) | Center for Internet Security, AZURE V1.3 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_docker_12)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+DOCKER+V1.2) | Center for Internet Security, Docker V1.2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_eks_11)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+EKS+V1.1) | Center for Internet Security, EKS V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_gke_11)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+GKE+V1.1) | Center for Internet Security, GKE V1.1 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/hazelops/terraform-aws-ec2-bastion/cis_kubernetes_16)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=hazelops%2Fterraform-aws-ec2-bastion&benchmark=CIS+KUBERNETES+V1.6) | Center for Internet Security, KUBERNETES V1.6 Compliance |





### Prerequisites
EC2:
   - System Manager Agent must be installed and running (version 2.3.672.0 or more recent)
   - The EC2 instance must have an IAM role with permission to invoke Systems Manager API (e.g. AmazonSSMManagedInstanceCore)
   
Local PC:
   - AWS Command Line Interface (CLI) (1.16.220 or more recent)
   - System Manager CLI extension (version 1.1.26.0 or more recent)
   
   https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
   
### Example:
```
module "bastion" {
    source    = "hazelops/ec2-bastion/aws"
    version   = "~> 2.0"
    
    aws_profile       = var.aws_profile 
    env               = var.env
    vpc_id            = local.vpc_id
    private_subnets   = local.private_subnets
    ec2_key_pair_name = local.ec2_key_pair_name

    ssh_forward_rules = [
      "LocalForward 11433 ${module.rds.sql_endpoint}:${module.rds.sql_port}",
      "LocalForward 44443 ${module.yourapp.alb_dns_name}:443"
    ]
}
```

### Usage:
1. Create `config` file in ~/.ssh folder with this:
```
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws --profile ${var.aws_profile} ssm send-command --instance-ids %h --document-name AWS-RunShellScript --comment 'Add an SSH public key to authorized_keys' --parameters commands='echo ${var.ssh_public_key} >> /home/ubuntu/.ssh/authorized_keys' &&  aws --profile <aws_profile> ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```
where `${var.aws_profile}` - actual aws cli profile; and  `${var.ssh_public_key}` - your ssh public key (~/.ssh/id_rsa.pub)

2. Options to run:
-  start tunnel:
  ```
  ssh -M -S bastion.sock -fNT ubuntu@<instance-id> -L <local_port>:<address of remote host>:<remote_port>
  ```
- check tunnel status:
  ```
  ssh -S bastion.sock -O check ubuntu@<instance-id>
  ```
- stop tunnel:
  ```
  ssh -S bastion.sock -O exit ubuntu@<instance-id>
  ```

 Where:
 
  `<instance-id>` - bastion ec2 instance-id (see in module output)
  
  `<local_port>` - port which you want to be used at local machine
  
  `<address of remote host>` - an address we want to make tunnel to.
  
  `<remote_port >` - port on remote instance to connect to. 
 
 Example of tunnel creation : 
 - For example, you need to create a tunnel from localhost to bastion host with ports: 10022: 
  ```
  ssh -M -S bastion.sock -fNT ubuntu@<instance-id> -L 10022:localhost:22
  ```


# v.1.0 AWS EC2 Bastion Terraform Module

Module creates ec2 bastion host with Public IP-address in VPC. 
   
### Example:
```
module "bastion" {
    source    = "hazelops/ec2-bastion/aws"
    version   = "~> 1.0"
    
    env               = var.env
    vpc_id            = local.vpc_id
    zone_id           = local.zone_id
    public_subnets    = local.public_subnets
    ec2_key_pair_name = local.ec2_key_pair_name

    ssh_forward_rules = [
      "LocalForward 11433 ${module.rds.sql_endpoint}:${module.rds.sql_port}",
      "LocalForward 44443 ${module.yourapp.alb_dns_name}:443"
    ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of network subnets that are allowed. According to PCI-DSS, CIS AWS and SOC2 providing a default wide-open CIDR is not secure. | `list(string)` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `any` | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | n/a | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `any` | n/a | yes |
| <a name="input_ext_security_groups"></a> [ext\_security\_groups](#input\_ext\_security\_groups) | External security groups to add to bastion host | `list(any)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.nano"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"bastion"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_ssh_forward_rules"></a> [ssh\_forward\_rules](#input\_ssh\_forward\_rules) | Rules that will enable port forwarding. SSH Config syntax | `list(string)` | `[]` | no |
| <a name="input_ssm_role"></a> [ssm\_role](#input\_ssm\_role) | n/a | `string` | `"arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cmd"></a> [cmd](#output\_cmd) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | n/a |
| <a name="output_ssh_config"></a> [ssh\_config](#output\_ssh\_config) | n/a |
