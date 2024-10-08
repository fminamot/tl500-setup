#!/bin/bash

source checkvar

echo -e "install-uj started"

# チーム用OCPプロジェクト作成
oc login --server=https://api.${CLUSTER_DOMAIN##apps.}:6443 -u $USER_NAME -p $PASSWORD
oc new-project ${TEAM_NAME}-ci-cd


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


# ArgoCD operator インストール (注意: version 0.4.9を指定)
helm upgrade --install argocd \
  --namespace ${TEAM_NAME}-ci-cd \
  -f /projects/tech-exercise/argocd-values.yaml \
  redhat-cop/gitops-operator --version 0.4.9
  
cd /projects/tech-exercise
git remote set-url origin https://${GITLAB_USER}:${GITLAB_PAT}@${GIT_SERVER}/${TEAM_NAME}/tech-exercise.git


# コードをGitLabにpush

cd /projects/tech-exercise
git add . 
git commit -am "ADD - argocd values file"
git push -u origin --all

# チーム名を修正しGitLabにpush

yq eval -i '.team=env(TEAM_NAME)' /projects/tech-exercise/values.yaml
yq eval ".source = \"https://$GIT_SERVER/$TEAM_NAME/tech-exercise.git\"" -i /projects/tech-exercise/values.yaml

sed -i "s|TEAM_NAME|$TEAM_NAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml

cd /projects/tech-exercise/
git add .
git commit -m  "ADD - correct project names"
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

sleep 30

# ArgoCDがデプロイされまで待つ
oc rollout status deployment argocd-server -n ${TEAM_NAME}-ci-cd --timeout 120s

# ArgoCDのコンソール（この時点ではApplicationはない）
echo "ArgoCD UI=https://$(oc get route argocd-server --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)"

# WebHook設定 (tech-exercise)
echo "Adding the webhook to tech-exercise project with GitLab REST API"

curl -s -k -H "PRIVATE-TOKEN: ${GITLAB_PAT}" "https://${GIT_SERVER}/api/v4/projects/" > /tmp/projects.json
TECH_EXERCISE_ID=$(cat /tmp/projects.json | jq --arg team_name ${TEAM_NAME} '.[] | select (.namespace.name == $team_name and .name == "tech-exercise")' | jq -r '.id')
# echo "TECH_EXERCISE_ID=${TECH_EXERCISE_ID}"

curl -k -X POST \
  -H "PRIVATE-TOKEN: ${GITLAB_PAT}" -H "Content-Type:application/json" \
  "https://${GIT_SERVER}/api/v4/projects/${TECH_EXERCISE_ID}/hooks/" \
  -d "{\"id\":${TECH_EXERCISE_ID}, \"url\":\"https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/api/webhook\", \"push_events\":true, \"enable_ssl_verification\":false}"

# WebHook追加 (tech-exerciseプロジェクトのSettings>Integrations)
echo "WebHook(tech-exercise) has been set to https://$(oc get route argocd-server --template='{{ .spec.host }}'/api/webhook  -n ${TEAM_NAME}-ci-cd)"

echo -e "install-uj done\n"

