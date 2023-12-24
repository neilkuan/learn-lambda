
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

locals {
  source_path   = "lambda-container"
  path_include  = ["**"]
  path_exclude  = ["**/__pycache__/**"]
  files_include = setunion([for f in local.path_include : fileset(local.source_path, f)]...)
  files_exclude = setunion([for f in local.path_exclude : fileset(local.source_path, f)]...)
  files         = sort(setsubtract(local.files_include, local.files_exclude))

  dir_sha = sha1(join("", [for f in local.files : filesha1("${local.source_path}/${f}")]))
}

variable "docker_host" {
  type = string
  description = ""
}

provider "docker" {
  ## check: docker context list                  
  host    = var.docker_host == ""? "unix:///var/run/docker.sock" : var.docker_host 

  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }

}

module "lambda_function_from_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "lambda-from-container-image"
  description   = "My awesome lambda function from container image"

  create_package = false

  package_type  = "Image"
  architectures = ["x86_64"]
  # architectures = ["arm64"]

  image_uri = module.docker_image.image_uri

  environment_variables = {
    Hello      = "World"
    Serverless = "Terraform"
    
  }

}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "lambda-from-container-image"

  use_image_tag = false # If false, sha of the image will be used

  source_path = local.source_path
  platform    = "linux/amd64"

  triggers = {
    dir_sha = local.dir_sha
  }
}
