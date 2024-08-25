#!/bin/bash

cd /tmp

# OpenShift CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.10/openshift-client-linux-4.10.67.tar.gz
tar xvf openshift*.tar.gz
chmod a+x oc
sudo mv ./oc /usr/local/bin

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh

# Yq
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq 
sudo chmod +x /usr/local/bin/yq

# Maven
sudo dnf install maven -y

# Tech Exercise
git config --global user.name "student"
git config --global user.email "student@redhatlabs.dev"

sudo rm -rf /projects/tech-exercise

sudo mkdir /projects
sudo chown student:student /projects
cd /projects
git clone -b main http://git.apps.ocp4.example.com/rht-labs/tech-exercise

