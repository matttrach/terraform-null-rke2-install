terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2"
    }
    # NOTE: this is only required for the examples
    # this is used by the aws_access and aws_server modules
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
    }
    # NOTE: this is only required for the examples
    # this is used by the aws_access module
    http = {
      source  = "hashicorp/http"
      version = ">= 2"
    }
  }
}