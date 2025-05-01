resource "aws_ecs_cluster" "github_runner" {
  name = "github-runner-cluster"
}

resource "aws_ecs_task_definition" "github_runner" {
  family                   = "github-actions-runner-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  task_role_arn           = aws_iam_role.runner_task_role.arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "github-runner"
      image     = var.github_runner_image_url
      essential = true
      environment = [
        {
          name = "GH_RUNNER_TOKEN"
          value: "actual_runtime_token"
        },
        {
          name  = "TOKEN_OF_GITHUB_PAT"
          value: "actual_runtime_token"
        },
        {
          name  = "GIT_REPO"
          value = var.git_repo
        },
        {
          name  = "GIT_BRANCH"
          value = var.execution_branch
        },
        {
          name  = "ENV_DIR"
          value = var.env_dir
        }
      ]
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