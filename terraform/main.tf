provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet_1}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "cicd-subnet_1"
    Project   = "cicd-demo"
    Terraform = "true"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet_2}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name      = "cicd-subnet_2"
    Project   = "cicd-demo"
    Terraform = "true"
  }
}

resource "aws_security_group" "app" {
  name   = "app security group for cicd"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.ssh_from}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "cicd-sg"
    Project   = "cicd-demo"
    Terraform = "true"
  }
}

resource "aws_sns_topic" "app" {
  name = "cicd-demo-topic"
}

resource "aws_codedeploy_app" "app" {
  name = "cicd-demo"
}

module "codedeploy_iam" {
  source = "github.com/callmeradical/terraformations//iam_aws"

  aws_region   = "${var.aws_region}"
  profile_name = "cicd-cd"
  role_name    = "cicd-cd"
  policy_name  = "cicd-cd"
  policy_path  = "${var.policy_path}/codedeploy.json"
}

resource "aws_iam_role" "cd" {
  name               = "codedeploy_role"
  assume_role_policy = "${file("policies/cdassume.json")}"
}

module "readonly_iam_asg" {
  source = "github.com/callmeradical/terraformations//iam_aws"

  aws_region   = "${var.aws_region}"
  profile_name = "cicd-ro"
  role_name    = "cicd-ro"
  policy_name  = "cicd-ro"
  policy_path  = "${var.policy_path}/ro.json"

  ## Don't forget to set a TF_VAR_policy_path
}

module "autoscaling_group" {
  source = "github.com/callmeradical/terraformations//asg_aws"

  ami_id            = "${var.ami_id}"
  aws_region        = "us-east-1"
  subnet_1          = "${aws_subnet.subnet_1.id}"
  subnet_2          = "${aws_subnet.subnet_2.id}"
  name              = "cicd-asg"
  project           = "cicd-demo"
  instance_type     = "t2.medium"
  key_name          = "aws1"
  security_group_id = "${aws_security_group.app.id}"
  instance_profile  = "${module.readonly_iam_asg.instance_profile_id}"
  user_data_path    = "${var.user_data_path}"

  ## Don't forget to set a TF_VAR_user_data_path
}
