resource "aws_ecs_task_definition" "github_runner" {
  family                   = "github-actions-runner-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.runner_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "github-runner"
      image     = var.github_runner_image_url
      essential = true
      environment = []
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/github-runner"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}