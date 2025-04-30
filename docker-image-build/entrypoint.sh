#!/bin/bash

set -euo pipefail

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
git clone -b "$GIT_BRANCH" "https://${GITHUB_PAT}@github.com/${GIT_REPO}.git"

# Terraform 実行
cd "/enviroment/$ENV_DIR"

echo "Running terraform init..."
terraform init -input=false

echo "Running terraform apply..."
terraform apply -auto-approve
