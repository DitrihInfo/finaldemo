provider "aws" {
  region = "us-east-2"
   
}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

#---------------------------------------------------
# Create ECR repository
#---------------------------------------------------

resource "aws_ecr_repository" "repository" {
  name                 = "${var.app}-${var.env}-${var.name_container}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
}
}

#---------------------------------------------------
# Create ECR lifecycle  policy
#---------------------------------------------------

resource "aws_ecr_lifecycle_policy" "repository" {
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 3 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 3
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

#---------------------------------------------------
# Create  null resource for build docker image for ECR
#---------------------------------------------------

resource "null_resource" "image_build" {
  provisioner "local-exec" {
    command = "docker image build ./web/. --tag ${var.name_container}"
  }
}

#---------------------------------------------------
# Create  null resource  (pause)  for ECR
#---------------------------------------------------

resource "time_sleep" "wait_10_seconds" {
    depends_on      = [null_resource.image_build]
  create_duration = "10s"
}

#---------------------------------------------------
# Create null resource - for login to ECR
#---------------------------------------------------

resource "null_resource" "login_ecr" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }
}

#---------------------------------------------------
# Create null resource - Tag image for ECR  
#---------------------------------------------------

resource "null_resource" "tag_image" {
  provisioner "local-exec" {
    command = "docker tag ${var.name_container}:latest ${local.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app}-${var.env}-${var.name_container}:latest"
  }
  depends_on = [time_sleep.wait_10_seconds]
}

#---------------------------------------------------
# Create null resource - push image to ECR  
#---------------------------------------------------

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = "docker push ${local.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.app}-${var.env}-${var.name_container}:latest"
  }
  depends_on = [time_sleep.wait_10_seconds]
}

#---------------------------------------------------
# Create ECR repository policy  
#---------------------------------------------------

resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.repository.name
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
}
EOF
}


