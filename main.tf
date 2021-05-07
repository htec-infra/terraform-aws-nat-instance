locals {
  name = "NATInstance-${var.name}"

  # This should prevent to create multiple NAT instances if you have only one
  # routing table defined for private subnets. Number of routing tables have to
  # be greater or equal to number of NAT instances i.e. number of specified public subnets
  subnets = slice(var.public_subnets, 0, min(length(var.public_subnets), length(data.aws_route_tables.private.ids)))

  common_tags = merge({
    Name = local.name
  }, var.tags)
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_route_tables" "private" {
  tags = {
    Name = "*private*"
  }
}


resource "aws_security_group" "this" {
  name_prefix = "nat-instances-${lower(var.name)}"
  vpc_id      = var.vpc_id
  description = "Security group for the NAT instance"
  tags        = local.common_tags

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }
}

# AMI of the latest Amazon Linux 2
data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix = local.name
  image_id    = var.image_id != "" ? var.image_id : data.aws_ami.this.id
  key_name    = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.this.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  user_data = data.template_cloudinit_config.user_data.rendered

  description = "Launch template for NAT instance ${var.name}"
  tags        = local.common_tags
}

data "template_cloudinit_config" "user_data" {

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/init.yaml", {
      # If we assign EIP, egress traffic should be routed through eth1 interface (new ENI)
      main_interface = var.allocate_elastic_ip ? "eth1" : "eth0"
    })
  }

  part {
    filename     = "runonce.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/templates/runonce.sh", {})
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix         = local.name
  min_size            = var.enabled ? 1 : 0
  max_size            = length(local.subnets)
  desired_capacity    = var.enabled ? length(local.subnets) : 0
  vpc_zone_identifier = local.subnets

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.use_spot_instance ? 0 : 1
      on_demand_percentage_above_base_capacity = var.use_spot_instance ? 0 : 100
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = var.instance_types
        content {
          instance_type = override.value
        }
      }
    }
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "net_interface" {
  source = "./modules/net-interface"

  for_each = {
    for subnet in local.subnets : subnet => subnet
  }

  subnet_id       = each.value
  allocate_eip    = var.allocate_elastic_ip
  security_groups = [aws_security_group.this.id]
}
