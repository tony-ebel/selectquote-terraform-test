resource "aws_ecr_repository" "rocket_league_internal" {
  name = "rocket-league-internal"

  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "rocket_league_web" {
  name = "rocket-league-web"

  image_tag_mutability = "MUTABLE"
}
