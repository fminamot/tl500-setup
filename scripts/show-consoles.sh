#!/bin/bash

source checkvar

echo "**** Team: ${TEAM_NAME} ****"

echo "\nOpenShift Web Console"
echo https://console-openshift-console.apps.ocp4.example.com

echo "\nGitLab Server"
echo "https://gitlab-ce.apps.ocp4.example.com"

echo "\nArgoCD UI"
echo "https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "\ntech-exercise WebHook"
echo https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/api/webhook

echo "\npet-battle-api WebHook"
echo "https://webhook-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "\nNexus UI"
echo "https://nexus-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo "\nSonarQube UI"
echo "https://sonarqube-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"
echo "username: admin, password: admin123"

echo "\nAllure UI"
echo "https://allure-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/allure-docker-service/projects/pet-battle-api/reports/latest/index.html"
