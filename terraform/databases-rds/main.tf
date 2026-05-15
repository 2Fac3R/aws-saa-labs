provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookup ---
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- DB Subnet Group ---
resource "aws_db_subnet_group" "main" {
  name       = "lab-db-subnet-group"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  tags = { Name = "lab-db-subnet-group" }
}

# --- Security Group for RDS ---
resource "aws_security_group" "rds" {
  name        = "lab-rds-sg"
  description = "Allow PostgreSQL traffic from the VPC"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # Decoupled approach: allow from the entire VPC CIDR
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lab-rds-sg" }
}

# --- AWS Secrets Manager (Architect Way) ---
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "lab/rds/postgresql-credentials"
  description             = "Credentials for the lab RDS instance"
  recovery_window_in_days = 0 # Forces immediate deletion if destroyed for lab purposes
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = var.db_password
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = 5432
    dbName   = aws_db_instance.main.db_name
  })
}

# --- RDS Instance (PostgreSQL) ---
resource "aws_db_instance" "main" {
  identifier             = "lab-db-instance"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "labdb"
  username               = "dbadmin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # SAA Exam Focus: Multi-AZ for High Availability
  multi_az = true

  # Maintenance & Backups
  backup_retention_period = 7
  skip_final_snapshot     = true # Warning: Set to false in production

  tags = { Name = "lab-db-multi-az" }
}
