#!/bin/zsh

source checkvar

watch -n 10 'oc get deploy -n ${TEAM_NAME}-ci-cd; oc get pods -n ${TEAM_NAME}-ci-cd'

