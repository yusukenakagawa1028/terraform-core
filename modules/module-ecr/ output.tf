output "github_runner_image_url" {
    value = "${aws_ecr_repository.github-runnner.repository_url}:latest"
}