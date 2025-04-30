module "ecr" {
    source = "../../modules/module-ecr"
}

module "runner-setup" {
    source                 = "../../modules/module-github-runner-setup"
    region                 = "ap-northeast-1"
    github_runner_image_url = module.ecr.github_runner_image_url
}

# resource "aws_eip" "test_eip" {
#   tags = {
#     Name = "test-eip"
#   }
# }