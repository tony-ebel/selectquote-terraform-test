resource "aws_ecr_repository" "rocket_league" {
  name = "rocket-league"

  image_tag_mutability = "MUTABLE"
}
