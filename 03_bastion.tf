
data "aws_ami" "ubuntu" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_iam_policy_document" "bastion_ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_ec2_role" {
  name               = "${var.prefix}-bastion-ec2-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.bastion_ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "bastion_ec2_ssm_managed_instance" {
  role       = aws_iam_role.bastion_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_ec2_profile" {
  name = "${var.prefix}-bastion-ec2-profile-${terraform.workspace}"
  role = aws_iam_role.bastion_ec2_role.name
}

resource "tls_private_key" "private_key" {
  count     = var.key_pair != null ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "bastion_private_key" {
  count = var.key_pair != null ? 0 : 1
  name  = "${var.prefix}-bastion-private-key-${terraform.workspace}"
  type  = "SecureString"
  value = tls_private_key.private_key[0].private_key_pem
}

resource "aws_ssm_parameter" "bastion_public_key_pem" {
  count = var.key_pair != null ? 0 : 1
  name  = "${var.prefix}-bastion-public-key-pem-${terraform.workspace}"
  type  = "String"
  value = tls_private_key.private_key[0].public_key_pem
}

resource "aws_ssm_parameter" "bastion_public_key_openssh" {
  count = var.key_pair != null ? 0 : 1
  name  = "${var.prefix}-bastion-public-key-openssh-${terraform.workspace}"
  type  = "String"
  value = tls_private_key.private_key[0].public_key_openssh
}

resource "aws_key_pair" "key_pair" {
  count      = var.key_pair != null ? 0 : 1
  key_name   = "${var.prefix}-key-pair-${terraform.workspace}"
  public_key = tls_private_key.private_key[0].public_key_openssh
}

resource "aws_instance" "bastion" {

  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t3a.micro"
  associate_public_ip_address = true
  key_name                    = var.key_pair != null ? var.key_pair : aws_key_pair.key_pair[0].key_name
  subnet_id                   = module.vpc.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.allow22.id, aws_security_group.allow80.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_ec2_profile.name

  user_data = <<-EOT
    #!/bin/bash
    # User data is executed as root
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts
    apt-get update
    apt-get install -y apache2 awscli
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Deployed via Terraform</h1>" | tee /var/www/html/index.html
    snap install amazon-ssm-agent --classic
    snap enable amazon-ssm-agent
    snap start amazon-ssm-agent
  EOT

  tags = {
    Name        = "${var.prefix}_bastion_${terraform.workspace}"
    Terraform   = "true"
    Project     = var.prefix
    Environment = terraform.workspace
  }

}
