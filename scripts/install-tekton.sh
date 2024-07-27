#!/bin/zsh

source checkvar

# プロジェクトをfork
cd /projects
git clone https://github.com/rht-labs/pet-battle-api.git -b v1.0.0

cd /projects/pet-battle-api
# commit ccb51ec より後はChartのバージョンが1.2.2に変更されている。
git checkout -b main
git remote remove origin
git remote add origin https://${GIT_SERVER}/${TEAM_NAME}/pet-battle-api.git
git push -u origin main

# Argo CD でパイプラインをクラスターに同期 
if [[ $(yq e '.applications[] | select(.name=="tekton-pipeline") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
    yq e '.applications += {"name": "tekton-pipeline","enabled": true,"source": "https://GIT_SERVER/TEAM_NAME/tech-exercise.git","source_ref": "main","source_path": "tekton","values": {"team": "TEAM_NAME","cluster_domain": "CLUSTER_DOMAIN","git_server": "GIT_SERVER"}}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|GIT_SERVER|$GIT_SERVER|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|TEAM_NAME|$TEAM_NAME|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
    sed -i "s|CLUSTER_DOMAIN|$CLUSTER_DOMAIN|" /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

# Tektonは変更をnexusへプッシュする。pet-battle-apiのsourceを更新しnexusを指すようにする

yq e '.applications.pet-battle-api.source |="http://nexus:8081/repository/helm-charts"' -i /projects/tech-exercise/pet-battle/test/values.yaml

cd /projects/tech-exercise
git add . 
git commit -m  "ADD - tekton pipelines config"
git push

cd /projects/pet-battle-api
mvn -ntp versions:set -DnewVersion=1.3.1

cd /projects/pet-battle-api
git add . 
git commit -m  "UPDATED - pet-battle-version to 1.3.1"
git push origin main

sleep 30

# webhookがデプロイされまで待つ
oc rollout status deployment el-gitlab-webhook -n ${TEAM_NAME}-ci-cd --timeout 120s

# GitLab>pet-battle-api>settings>integrationに指定するリンク
echo "WebHook(pet battle api)=https://$(oc -n ${TEAM_NAME}-ci-cd get route webhook --template='{{ .spec.host }}')"

echo "install-tekton done"

# Pipelines -> Pipelines でパイプラインの実行状況を確認
#tkn -n ${TEAM_NAME}-ci-cd pr logs -Lf 
