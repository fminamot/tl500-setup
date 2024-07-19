#!/bin/zsh

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
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🍳 ADD - sonarqube creds sealed secret 🍳"
git push

oc get secrets -n ${TEAM_NAME}-ci-cd | grep sonarqube-auth

# Sonarqubeをubiquitous-journey/values-tooling.yamlに追加 

if [[ $(yq e '.applications[] | select(.name=="sonarqube") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
   yq e '.applications += {"name":"sonarqube","enabled":true,"source":"https://redhat-cop.github.io/helm-charts","chart_name":"sonarqube","source_ref":"0.1.0","values":{"account":{"existingSecret":"sonarqube-auth"},"initContainers":true,"plugins":{"install":["https://github.com/checkstyle/sonar-checkstyle/releases/download/9.2/checkstyle-sonar-plugin-9.2.jar","https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/2.0.8/sonar-dependency-check-plugin-2.0.8.jar"]}}}
' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

cd /projects/tech-exercise
git add .
git commit -m  "🦇 ADD - sonarqube 🦇"
git push

# Sonarqube UIで確認 (admin/admin123)
echo https://$(oc get route sonarqube --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)

# Sonar スキャンによる Tekton パイプラインの拡張