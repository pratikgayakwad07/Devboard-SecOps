resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-${var.environment}-postgres"
  description = "PostgreSQL access from DevBoard EKS worker nodes only"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-postgres"
  })
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = var.eks_node_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL from DevBoard EKS nodes"
}
