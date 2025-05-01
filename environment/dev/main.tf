module "ecr" {
    source = "../../modules/module-ecr"
}

module "runner-setup" {
    source                  = "../../modules/module-github-runner-setup"
    region                  = "ap-northeast-1"
    github_runner_image_url = module.ecr.github_runner_image_url
    execution_branch        = "main"
    env_dir                 = "dev"
    git_repo                = "yusukenakagawa1028/terraform-core"
}