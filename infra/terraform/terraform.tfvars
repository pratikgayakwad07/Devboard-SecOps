aws_region     = "us-east-1"
project_name   = "devboard"
environment    = "prod"
owner          = "platform-team"
cost_center    = "engineering"

github_owner      = "pratikgayakwad07"
github_repository = "Devboard-SecOps"
github_branch     = "master"

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_cidr            = "10.40.0.0/16"
public_subnet_cidrs = [
  "10.40.0.0/20",
  "10.40.16.0/20",
  "10.40.32.0/20",
]
private_subnet_cidrs = [
  "10.40.64.0/20",
  "10.40.80.0/20",
  "10.40.96.0/20",
]
database_subnet_cidrs = [
  "10.40.128.0/24",
  "10.40.129.0/24",
  "10.40.130.0/24",
]

# Use false for one NAT gateway per AZ in production; true lowers demo cost.
single_nat_gateway = false

eks_cluster_version              = "1.33"
eks_endpoint_public_access_cidrs = ["203.0.113.10/32"]
node_instance_types               = ["t3.micro"]
node_min_size                     = 2
node_desired_size                 = 3
node_max_size                     = 4
node_disk_size_gib                = 20

postgres_engine_version          = "16.4"
postgres_database_name           = "devboard"
postgres_master_username         = "devboard_admin"
postgres_instance_class          = "db.t4g.medium"
postgres_allocated_storage_gib   = 20
postgres_max_allocated_storage_gib = 30
postgres_backup_retention_days   = 7
postgres_multi_az                = true
postgres_deletion_protection     = true
postgres_skip_final_snapshot     = false
postgres_final_snapshot_identifier = "devboard-prod-final-snapshot"
