#!/bin/bash

cd /tmp

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

# Yq
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq 
sudo chmod +x /usr/local/bin/yq

# Tech Exercise
sudo mkdir /projects
sudo chown student:student /projects
cd /projects
git clone -b main http://git.apps.ocp4.example.com/rht-labs/tech-exercise

git config --global user.name "student"
git config --global user.email "student@redhatlabs.dev"

# Maven
sudo dnf install maven