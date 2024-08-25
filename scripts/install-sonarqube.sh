#!/bin/bash

source checkvar

cat << EOF > /tmp/sonarqube-auth.yaml
apiVersion: v1
data:
  username: "$(echo -n admin | base64 -w0)"
  password: "$(echo -n admin123 | base64 -w0)"
  currentAdminPassword: "$(echo -n admin | base64 -w0)"
kind: Secret
metadata:
  labels:
    credential.sync.jenkins.openshift.io: "true"
  name: sonarqube-auth
EOF

oc apply -f /tmp/sonarqube-auth.yaml

cd /projects/tech-exercise
git pull
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "ADD - sonarqube creds sealed secret"
git push

oc get secrets -n ${TEAM_NAME}-ci-cd | grep sonarqube-auth

# Sonarqubeをubiquitous-journey/values-tooling.yamlに追加 

if [[ $(yq e '.applications[] | select(.name=="sonarqube") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
   yq e '.applications += {"name":"sonarqube","enabled":true,"source":"https://redhat-cop.github.io/helm-charts","chart_name":"sonarqube","source_ref":"0.1.0","values":{"account":{"existingSecret":"sonarqube-auth"},"initContainers":true,"plugins":{"install":["https://github.com/checkstyle/sonar-checkstyle/releases/download/9.2/checkstyle-sonar-plugin-9.2.jar","https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/2.0.8/sonar-dependency-check-plugin-2.0.8.jar"]}}}
' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

# sonarqube-quality-gate-check タスク定義追加
cd /projects/tech-exercise
cat <<'EOF' >> tekton/templates/tasks/sonarqube-quality-gate-check.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: sonarqube-quality-gate-check
spec:
  description: >-
    This Task can be used to check sonarqube quality gate
  workspaces:
    - name: output
    - name: sonarqube-auth
      optional: true
  params:
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
      type: string
    - name: IMAGE
      description: the image to use
      type: string
      default: "quay.io/eformat/openshift-helm:latest"
  steps:
  - name: check
    image: $(params.IMAGE)
    script: |
      #!/bin/sh
      test -f $(workspaces.sonarqube-auth.path) || export SONAR_USER="$(cat $(workspaces.sonarqube-auth.path)/username):$(cat $(workspaces.sonarqube-auth.path)/password)"
  
      cd $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      TASKFILE=$(find . -type f -name report-task.txt)
      if [ -z ${TASKFILE} ]; then
        echo "Task File not found"
        exit 1
      fi
      echo ${TASKFILE}

      TASKURL=$(cat ${TASKFILE} | grep ceTaskUrl)
      TURL=${TASKURL##ceTaskUrl=}
      if [ -z ${TURL} ]; then
        echo "Task URL not found"
        exit 1
      fi
      echo ${TURL}

      AID=$(curl -u ${SONAR_USER} -s $TURL | jq -r .task.analysisId)
      if [ -z ${AID} ]; then
        echo "Analysis ID not found"
        exit 1
      fi
      echo ${AID}

      SERVERURL=$(cat ${TASKFILE} | grep serverUrl)
      SURL=${SERVERURL##serverUrl=}
      if [ -z ${SURL} ]; then
        echo "Server URL not found"
        exit 1
      fi
      echo ${SURL}

      BUILDSTATUS=$(curl -u ${SONAR_USER} -s $SURL/api/qualitygates/project_status?analysisId=${AID} | jq -r .projectStatus.status)
      if [ "${BUILDSTATUS}" != "OK" ]; then
        echo "Failed Quality Gate - please check - $SURL/api/qualitygates/project_status?analysisId=${AID}"
        exit 1
      fi

      echo "Quality Gate Passed OK - $SURL/api/qualitygates/project_status?analysisId=${AID}"
      exit 0
EOF

cd /projects/tech-exercise
git add . 
git commit -m  "ADD - sonarqube"
git push

sleep 30

# Sonarqubeがデプロイされまで待つ
oc rollout status deployment sonarqube-sonarqube -n ${TEAM_NAME}-ci-cd --timeout 120s

# Sonarqube UIで確認 (admin/admin123)
echo "Sonarqube UI=https://$(oc get route sonarqube --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)"

echo -e "install-sonarqube done\n\n"
# Sonar スキャンによる Tekton パイプラインの拡張
