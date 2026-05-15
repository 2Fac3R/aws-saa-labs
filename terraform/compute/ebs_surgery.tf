# --- Secondary EBS Volume (Block Storage) ---
resource "aws_ebs_volume" "secondary_data" {
  availability_zone = "us-east-1a" # Must match Lab 3 EC2 AZ
  size              = 10
  type              = "gp3"

  tags = { Name = "lab-secondary-ebs" }
}

# --- Attachment ---
resource "aws_volume_attachment" "secondary_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.secondary_data.id
  instance_id = aws_instance.web.id
}

# --- Snapshot (Backup) ---
resource "aws_ebs_snapshot" "backup" {
  volume_id = aws_ebs_volume.secondary_data.id

  tags = { Name = "lab-ebs-snapshot-manual" }
}
