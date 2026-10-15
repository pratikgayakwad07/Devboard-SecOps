data "aws_ssm_parameter" "eks_optimized_ami" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-${var.environment}-eks-control-plane"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "nodes" {
  name = "${var.project_name}-${var.environment}-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
  ])

  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-${var.environment}-eks-control-plane"
  description = "EKS control plane traffic from DevBoard worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-control-plane"
  })
}

resource "aws_security_group" "nodes" {
  name        = "${var.project_name}-${var.environment}-eks-nodes"
  description = "EKS managed worker node communication"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-nodes"
  })
}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Worker nodes to the Kubernetes API"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "tcp"
  description                  = "EKS control plane to worker kubelet and webhook ports"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_self" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "-1"
  description                  = "Worker node and pod communication"
}

resource "aws_vpc_security_group_egress_rule" "cluster_all" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Control plane outbound access"
}

resource "aws_vpc_security_group_egress_rule" "nodes_all" {
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Worker nodes outbound access through private subnet routing"
}

resource "aws_eks_cluster" "this" {
  name                          = "${var.project_name}-${var.environment}"
  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = true

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.endpoint_public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_vpc_security_group_ingress_rule.cluster_from_nodes,
    aws_vpc_security_group_egress_rule.cluster_all,
  ]

  tags = var.common_tags
}

resource "aws_launch_template" "nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-"
  image_id    = data.aws_ssm_parameter.eks_optimized_ami.value
  user_data = base64encode(templatefile("${path.module}/node-user-data.yaml.tftpl", {
    cluster_name     = aws_eks_cluster.this.name
    cluster_endpoint = aws_eks_cluster.this.endpoint
    cluster_ca       = aws_eks_cluster.this.certificate_authority[0].data
    service_cidr     = aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr
  }))
  update_default_version = true

  vpc_security_group_ids = [aws_security_group.nodes.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size_gib
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.project_name}-${var.environment}-eks-node" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.common_tags
  }

  tags = var.common_tags
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.environment}-workers"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  scaling_config {
    min_size     = var.node_min_size
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.node_policies,
    aws_eks_cluster.this,
  ]

  tags = var.common_tags
}
