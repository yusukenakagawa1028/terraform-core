variable "region" {
  type = string
  default = "ap-northeast-1"
}

variable "github_runner_image_url" {
  type = string
}

variable "execution_branch" {
  type = string
}

variable "git_repo" {
  type = string
}
variable "env_dir" {
  type = string
}