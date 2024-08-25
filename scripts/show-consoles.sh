#!/bin/bash

source checkvar

echo "**** Team: ${TEAM_NAME} ****"

echo -e "\nOpenShift Web Console"
echo https://console-openshift-console.apps.ocp4.example.com

echo -e "\nGitLab Server"
echo "https://gitlab-ce.apps.ocp4.example.com"

echo -e "\nArgoCD UI"
echo "https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo -e "\ntech-exercise WebHook"
echo https://argocd-server-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/api/webhook

echo -e "\npet-battle-api WebHook"
echo "https://webhook-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo -e "\nNexus UI"
echo "https://nexus-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"

echo -e "\nSonarQube UI"
echo "https://sonarqube-${TEAM_NAME}-ci-cd.apps.ocp4.example.com"
echo "username: admin, password: admin123"

echo -e "\nAllure UI"
echo "https://allure-${TEAM_NAME}-ci-cd.apps.ocp4.example.com/allure-docker-service/projects/pet-battle-api/reports/latest/index.html"
