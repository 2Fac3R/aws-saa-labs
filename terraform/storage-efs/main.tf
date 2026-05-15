provider "aws" {
  region = var.aws_region
}

# --- Remote State Lookups ---
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "aws-saa-labs-tfstate-444386042261-us-east-1"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# --- Security Group for EFS ---
resource "aws_security_group" "efs" {
  name        = "lab-efs-sg"
  description = "Allow NFS traffic from the VPC"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    # SAA Best Practice: Allow from the CIDR of our private subnets
    # This breaks the circular dependency on the ASG state
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_id != "" ? "10.0.0.0/16" : "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lab-efs-sg" }
}

# --- Elastic File System (EFS) ---
resource "aws_efs_file_system" "shared_data" {
  creation_token = "lab-efs-shared"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = { Name = "lab-shared-filesystem" }
}

# --- Mount Targets (One per AZ) ---
resource "aws_efs_mount_target" "primary" {
  file_system_id  = aws_efs_file_system.shared_data.id
  subnet_id       = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "secondary" {
  file_system_id  = aws_efs_file_system.shared_data.id
  subnet_id       = data.terraform_remote_state.networking.outputs.private_subnet_ids[1]
  security_groups = [aws_security_group.efs.id]
}
