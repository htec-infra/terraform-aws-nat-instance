# AWS NAT Instance

## Overview


### Features
- Autoscaling group that spreads nat instances across the AWS region
- Spot instance support
- Optional Elastic IP 

## Usage

```terraform
module "nat_instance" {
  source              = "github.com/htec-infra/terraform-aws-nat-instance"
  environment         = "Development"
  name                = "Test"
  namespace           = "PoC"
  vpc_id              = "vpc-123456"
  public_subnets      = ["subnet-123456789"]
  allocate_elastic_ip = true
}
```



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_net_interface"></a> [net\_interface](#module\_net\_interface) | ./modules/net-interface |  |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route_tables.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [template_cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocate_elastic_ip"></a> [allocate\_elastic\_ip](#input\_allocate\_elastic\_ip) | n/a | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable or not costly resources | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | How long ASG should wait before a health-check starts | `number` | `180` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | AMI of the NAT instance. Default to the latest Amazon Linux 2 | `string` | `""` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Candidates of spot instance type for the NAT instance. This is used in the mixed instances policy | `list(string)` | <pre>[<br>  "t3a.nano",<br>  "t3.nano"<br>]</pre> | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the key pair for the NAT instance. You can set this to assign the key pair to the NAT instance | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for all the resources as identifier | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Module namespace | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | IDs of the public subnets to place the NAT instance | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to resources created with this module | `map(string)` | `{}` | no |
| <a name="input_use_spot_instance"></a> [use\_spot\_instance](#input\_use\_spot\_instance) | Whether to use spot or on-demand EC2 instance | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role for the NAT instance |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | ID of the security group of the NAT instance |
<!-- END_TF_DOCS -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)

### Configurations

- Configure pre-commit hooks
```sh
pre-commit install
```

### Tests

- Tests are available in `test` directory
- In the test directory, run the below command
```sh
go test
```
