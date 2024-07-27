#!/bin/zsh

source checkvar

oc get deploy -n ${TEAM_NAME}-ci-cd
oc get pods -n ${TEAM_NAME}-ci-cd



