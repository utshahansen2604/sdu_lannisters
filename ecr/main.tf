provider "aws" {
  profile="ShellPowerUser"
  region="ap-south-1"
}

resource "aws_ecr_repository" "lannisters_repo_webapp" {
  name                 = "lannisters_repo_webapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lannisters_repo_apigateway" {
  name                 = "lannisters_repo_apigateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lannisters_repo_mongodb" {
  name                 = "lannisters_repo_mongodb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lannisters_repo_position_simulator" {
  name                 = "lannisters_repo_position_simulator"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lannisters_repo_position_tracker" {
  name                 = "lannisters_repo_position_tracker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "lannisters_repo_queue" {
  name                 = "lannisters_repo_queue"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
