#!/bin/bash

set -euo pipefail

# リポジトリのルートに移動してrunnerをセットアップ
./config.sh --url https://github.com/${GIT_REPO} \
            --token "$GH_RUNNER_TOKEN" \
            --unattended \
            --labels ecs-runner

# Actions runner を起動
./run.sh



if [ -z "${GITHUB_PAT:-}" ]; then
  echo "ERROR: GITHUB_PAT is not set"
  exit 1
fi

if [ -z "${GIT_REPO:-}" ]; then
  echo "ERROR: GIT_REPO is not set (e.g. your-org/your-repo)"
  exit 1
fi

GIT_BRANCH="${GIT_BRANCH:-main}"

# Clone
echo "Cloning Terraform code from GitHub..."
git clone "https://github.com/${GIT_REPO}.git"

# Terraform 実行
cd "/enviroment/$ENV_DIR"

echo "Running terraform init..."
terraform init

echo "Running terraform apply..."
terraform apply -auto-approve
