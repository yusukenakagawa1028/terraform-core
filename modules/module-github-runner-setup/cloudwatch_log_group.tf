resource "aws_cloudwatch_log_group" "runner_logs" {
  name              = "/ecs/github-runner"
  retention_in_days = 7
}
