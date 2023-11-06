provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "mutant" {
  name = "mutant"
}

import {
  to = aws_ecr_repository.mutant
  id = "mutant"
}
