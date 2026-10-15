resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-${var.environment}-postgres"
  description = "Private subnets for DevBoard PostgreSQL"
  subnet_ids  = var.database_subnet_ids

  tags = var.common_tags
}

resource "aws_db_instance" "this" {
  identifier                  = "${var.project_name}-${var.environment}-postgres"
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = true

  allocated_storage     = var.allocated_storage_gib
  max_allocated_storage = var.max_allocated_storage_gib
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = false

  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_days
  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.final_snapshot_identifier
  copy_tags_to_snapshot      = true
  apply_immediately          = false

  performance_insights_enabled = true
  monitoring_interval          = 0

  tags = var.common_tags
}
