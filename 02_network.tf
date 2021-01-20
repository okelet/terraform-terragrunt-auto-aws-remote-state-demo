module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}_vpc_${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Project     = var.prefix
    Environment = terraform.workspace
  }

}

resource "aws_security_group" "allow80" {

  name   = "${var.prefix}_allow_80_${terraform.workspace}"
  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}_allow_80_${terraform.workspace}"
    Terraform   = "true"
    Project     = var.prefix
    Environment = terraform.workspace
  }

}

resource "aws_security_group" "allow22" {

  name   = "${var.prefix}_allow_22_${terraform.workspace}"
  vpc_id = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix}_allow_22_${terraform.workspace}"
    Terraform   = "true"
    Project     = var.prefix
    Environment = terraform.workspace
  }

}
