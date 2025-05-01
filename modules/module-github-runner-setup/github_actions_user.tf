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
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::pvdev-terraform-backend-bucket",
          "arn:aws:s3:::pvdev-terraform-backend-bucket/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/5d0fdd53-9f6a-4161-bd4a-5eeca512041f"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_attach_policy" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_run_ecs.arn
}

data "aws_caller_identity" "current" {}
