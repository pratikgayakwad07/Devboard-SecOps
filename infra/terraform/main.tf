module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.21"

  name = "${var.project_name}-${var.environment}"
  cidr = var.vpc_cidr

  azs                  = var.availability_zones
  public_subnets       = var.public_subnet_cidrs
  private_subnets      = var.private_subnet_cidrs
  database_subnets     = var.database_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                              = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }

  database_subnet_tags = {
    "devboard.io/purpose" = "database"
  }

  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  project_name                 = var.project_name
  environment                  = var.environment
  cluster_version              = var.eks_cluster_version
  vpc_id                       = module.network.vpc_id
  private_subnet_ids           = module.network.private_subnets
  endpoint_public_access_cidrs = var.eks_endpoint_public_access_cidrs
  node_instance_types          = var.node_instance_types
  node_min_size                = var.node_min_size
  node_desired_size            = var.node_desired_size
  node_max_size                = var.node_max_size
  node_disk_size_gib           = var.node_disk_size_gib
  common_tags                  = local.common_tags
}

module "database" {
  source = "./modules/database"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  database_subnet_ids        = module.network.database_subnets
  eks_node_security_group_id = module.eks.node_security_group_id
  engine_version             = var.postgres_engine_version
  database_name              = var.postgres_database_name
  master_username            = var.postgres_master_username
  instance_class             = var.postgres_instance_class
  allocated_storage_gib      = var.postgres_allocated_storage_gib
  max_allocated_storage_gib  = var.postgres_max_allocated_storage_gib
  backup_retention_days      = var.postgres_backup_retention_days
  multi_az                   = var.postgres_multi_az
  deletion_protection        = var.postgres_deletion_protection
  skip_final_snapshot        = var.postgres_skip_final_snapshot
  final_snapshot_identifier  = var.postgres_final_snapshot_identifier
  common_tags                = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  common_tags  = local.common_tags
}

module "github_actions" {
  source = "./modules/github-actions"

  project_name        = var.project_name
  environment         = var.environment
  github_owner        = var.github_owner
  github_repository   = var.github_repository
  github_branch       = var.github_branch
  cluster_arn         = module.eks.cluster_arn
  ecr_repository_arns = module.ecr.repository_arns
  database_secret_arn = module.database.master_secret_arn
  common_tags         = local.common_tags
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = module.github_actions.cluster_deployer_role_arn
  type              = "STANDARD"
  kubernetes_groups = ["devboard-deployers"]

  tags = local.common_tags
}
