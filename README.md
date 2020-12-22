# v.2.0 AWS Terraform Module - EC2 Bastion over SSM 
Module creates ec2 bastion host in private subnet (without Public IP-address) of VPC and connects it to System Manager and copy your ssh public key to .ssh/authorized_keys on the bastion ec2. 
Bastion host can be controlled by Session Manager documents.

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
