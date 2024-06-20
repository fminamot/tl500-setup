#!/bin/zsh

source basic
source print_vars
print_vars()

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

kubeseal < /tmp/sonarqube-auth.yaml > /tmp/sealed-sonarqube-auth.yaml \
    -n ${TEAM_NAME}-ci-cd \
    --controller-namespace tl500-shared \
    --controller-name sealed-secrets \
    -o yaml
    
cat /tmp/sealed-sonarqube-auth.yaml| grep -E 'username|password|currentAdminPassword'

# 以下をubiquitous-journey/values-tooling.yamlに追加 (username, password, currentAdminPasswordはコピー)
 - name: sonarqube-auth
   type: Opaque
   labels:
     credential.sync.jenkins.openshift.io: "true"
   data:
    username: <username>
    password: <password>
    currentAdminPassword: <currentAdminPassword>

cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml
git commit -m  "🍳 ADD - sonarqube creds sealed secret 🍳"
git push

oc get secrets -n ${TEAM_NAME}-ci-cd | grep sonarqube-auth

# 以下をubiquitous-journey/values-tooling.yamlに追加
# Sonarqube
  - name: sonarqube
    enabled: true
    source: https://redhat-cop.github.io/helm-charts
    chart_name: sonarqube
    source_ref: "0.1.0"
    values:
      account:
        existingSecret: sonarqube-auth
      initContainers: true
      plugins:
        install:
          - https://github.com/checkstyle/sonar-checkstyle/releases/download/9.2/checkstyle-sonar-plugin-9.2.jar
          - https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/2.0.8/sonar-dependency-check-plugin-2.0.8.jar

cd /projects/tech-exercise
git add .
git commit -m  "🦇 ADD - sonarqube 🦇"
git push

# Sonarqube UIで確認
echo https://$(oc get route sonarqube --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)
