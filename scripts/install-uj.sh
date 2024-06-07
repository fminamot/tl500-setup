#!/bin/zsh -xe
#
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

echo "********** Basic Settings"

# 実際に払い出された各種情報をここに設定する
export USER_NAME=user1
export PASSWORD=<pass>
export TEAM_NAME=team1
export CLUSTER_DOMAIN=<domain>
export GIT_SERVER="gitlab-ce.${CLUSTER_DOMAIN}"
export GITLAB_USER=${USER_NAME}
export GITLAB_PASSWORD=${PASSWORD}

echo export TEAM_NAME=$TEAM_NAME | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN=$CLUSTER_DOMAIN | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER=$GIT_SERVER | tee -a ~/.bashrc -a ~/.zshrc
#source ~/.zshrc

echo "TEAM_NAME=${TEAM_NAME}"
echo "CLUSTER_DOMAIN=${CLUSTER_DOMAIN}"
echo "GIT_SERVER${GIT_SERVER}"
echo "GITLAB_USER=${GITLAB_USER}"
echo "GITLAB_PASSWORD=${GITLAB_PASSWORD}"

# チーム用OCPプロジェクト作成
oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u $USER_NAME -p $PASSWORD 
oc new-project ${TEAM_NAME}-ci-cd

echo "********** GitLab PAT"

gitlab_pat

echo "GITLAB_PAT=${GITLAB_PAT}"

echo "********** Argo CD"

helm repo add redhat-cop https://redhat-cop.github.io/helm-charts

run()
{
  NS=$(oc get subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators \
    -o jsonpath='{.spec.config.env[?(@.name=="ARGOCD_CLUSTER_CONFIG_NAMESPACES")].value}')
  opp=
  if [ -z $NS ]; then
    NS="${TEAM_NAME}-ci-cd"
    opp=add
  elif [[ "$NS" =~ .*"${TEAM_NAME}-ci-cd".* ]]; then
    echo "${TEAM_NAME}-ci-cd already added."
    return
  else
    NS="${TEAM_NAME}-ci-cd,${NS}"
    opp=replace
  fi
  oc -n openshift-operators patch subscriptions.operators.coreos.com/openshift-gitops-operator --type=json \
    -p '[{"op":"'$opp'","path":"/spec/config/env/1","value":{"name": "ARGOCD_CLUSTER_CONFIG_NAMESPACES", "value":"'${NS}'"}}]'
  echo "EnvVar set to: $(oc get subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators \
    -o jsonpath='{.spec.config.env[?(@.name=="ARGOCD_CLUSTER_CONFIG_NAMESPACES")].value}')"
}
run

cat << EOF > /projects/tech-exercise/argocd-values.yaml
ignoreHelmHooks: true
operator: []
namespaces:
  - ${TEAM_NAME}-ci-cd
argocd_cr:
  initialRepositories: |
    - url: https://${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git
      type: git
      passwordSecret:
        key: password
        name: git-auth
      usernameSecret:
        key: username
        name: git-auth
      insecure: true
EOF


# ArgoCD operator インストール
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  -f /projects/tech-exercise/argocd-values.yaml \
  redhat-cop/gitops-operator
  

echo "********** Ubiquitous-journey"

cd /projects/tech-exercise
git remote set-url origin https://${GITLAB_USER}:${GITLAB_PAT}@${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git

# コードをGitLabにpush

cd /projects/tech-exercise
git add .
git commit -am "🐙 ADD - argocd values file 🐙"
git push -u origin --all

# チーム名を修正しGitLabにpush

yq eval -i '.team=env(TEAM_NAME)' /projects/tech-exercise/values.yaml
yq eval ".source = \"https://$GIT_SERVER/$TEAM_NAME/tech-exercise.git\"" -i /projects/tech-exercise/values.yaml

sed -i "s|TEAM_NAME|$TEAM_NAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml

cd /projects/tech-exercise/
git add .
git commit -m  "🦆 ADD - correct project names 🦆"
git push

# シークレットgit-authをOCPに作成

cat <<EOF | oc apply -n ${TEAM_NAME}-ci-cd -f -
  apiVersion: v1
  data:
    password: "$(echo -n ${GITLAB_PAT} | base64 -w0)"
    username: "$(echo -n ${GITLAB_USER} | base64 -w0)"
  kind: Secret
  type: kubernetes.io/basic-auth
  metadata:
    annotations:
      tekton.dev/git-0: https://${GIT_SERVER}
      sealedsecrets.bitnami.com/managed: "true"
    labels:
      credential.sync.jenkins.openshift.io: "true"
    name: git-auth
EOF

# ユビキタスジャーニーにツールをインストール (この時点でArgoCDにApplicationは存在しない)

cd /projects/tech-exercise
helm upgrade --install uj --namespace ${TEAM_NAME}-ci-cd .

# ArgoCDコンソールにUbiquitous-journey登場

oc get projects | grep ${TEAM_NAME}
oc get pods -n ${TEAM_NAME}-ci-cd -w

# ArgoCDのコンソール（この時点ではApplicationはない）
echo https://$(oc get route argocd-server --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)

echo "install-uj done"

