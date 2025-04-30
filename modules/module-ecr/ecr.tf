resource "aws_ecr_repository" "github-runnner" {
    name = "github-runnner-repo"
    tags = {
        Name = "github-runnner-repo"
    }
}