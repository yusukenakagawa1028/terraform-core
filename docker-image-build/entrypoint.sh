#!/bin/bash
set -e

echo "Starting GitHub Actions Runner setup..."

if [[ -z "$GH_RUNNER_TOKEN" || -z "$GIT_REPO" ]]; then
  echo "Missing required environment variables."
  exit 1
fi

echo "Registering runner for https://github.com/${GIT_REPO}..."
./config.sh --url "https://github.com/${GIT_REPO}" \
            --token "$GH_RUNNER_TOKEN" \
            --unattended \
            --labels ecs-runner

echo "Starting runner..."
./run.sh
