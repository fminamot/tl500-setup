#!/bin/zsh -xe
# 設定内容:
# 
# 準備:
# 1. workspace作成
# https://raw.githubusercontent.com/rht-labs/enablement-framework/main/codereadyworkspaces/tl500-devfile-v2.yaml
# 2. GitLab Podが起動していることを確認
# 3. GitLabプロジェクト作成
#  https://gitlab-ce.<domain>/ にログイン
# team1のpublicグループ作成
# tech-exerciseという新規internalプロジェクト
#

source basic

echo "********** Basic Settings"

echo "TEAM_NAME=${TEAM_NAME}"
echo "CLUSTER_DOMAIN=${CLUSTER_DOMAIN}"
echo "GIT_SERVER${GIT_SERVER}"
echo "GITLAB_USER=${GITLAB_USER}"
echo "GITLAB_PASSWORD=${GITLAB_PASSWORD}"


echo export TEAM_NAME=$TEAM_NAME | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN=$CLUSTER_DOMAIN | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER=$GIT_SERVER | tee -a ~/.bashrc -a ~/.zshrc


echo "********** GitLab PAT"

gitlab_pat

echo "GITLAB_PAT=${GITLAB_PAT}"

