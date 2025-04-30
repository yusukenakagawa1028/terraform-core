#!/bin/bash
set -e

./config.sh --url https://github.com/<user>/<repo> \
            --token "$GH_RUNNER_TOKEN" \
            --unattended \
            --labels ecs-runner

./run.sh  # この中でGitHub Actionsが接続してジョブを実行

./config.sh remove --token "$GH_RUNNER_TOKEN"
