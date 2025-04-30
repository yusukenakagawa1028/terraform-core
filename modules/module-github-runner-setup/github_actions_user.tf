resource "aws_iam_user" "github_actions" {
  name = "github-actions-runner-user"
}

resource "aws_iam_policy" "github_actions_run_ecs" {
  name = "GitHubActionsRunECSTask"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeClusters"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole",
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeClusters"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-runner-task-role"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_attach_policy" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_run_ecs.arn
}

data "aws_caller_identity" "current" {}
