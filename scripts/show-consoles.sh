#!/bin/zsh

source checkvar

echo "**** Team: ${TEAM_NAME} ****"

echo "OpenShift Web Console"
echo https://console-openshift-console.apps.ocp4.example.com

echo "GitLab Server"
echo "https://gitlab-ce.apps.ocp4.example.com"

echo "ArgoCD UI"
echo "https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "tech-exercise WebHook"
echo https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/api/webhook

pecho "pet-battle-api WebHook"
echo "https://webhook-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "Nexus UI"
echo "https://nexus-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "SonarQube UI"
echo "https://sonarqube-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"
echo "username: admin, password: admin123"

echo "Allure UI"
echo "https://allure-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/allure-docker-service/projects/pet-battle-api/reports/latest/index.html"
