#!/bin/zsh

source basic

echo "********** GitLab PAT"

gitlab_pat () {
        [ -z "$GIT_SERVER" ] && echo "Warning: must supply GIT_SERVER in env" && return
        [ -z "$GITLAB_USER" ] && echo "Warning: must supply GITLAB_USER in env" && return
        [ -z "$GITLAB_PASSWORD" ] && echo "Warning: must supply GITLAB_PASSWORD in env" && return
        gitlabEncodedPassword=$(echo ${GITLAB_PASSWORD} | perl -MURI::Escape -ne 'chomp;print uri_escape($_)') 
        gitlab_basic_auth_string="Basic $(echo -n ${GITLAB_USER}:${gitlabEncodedPassword} | base64)" 
        body_header=$(curl -k -L -s -H "Authorization: ${gitlab_basic_auth_string}" -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/sign_in") 
        csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p) 
        curl -k -s -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt -c /tmp/cookies.txt -i "https://${GIT_SERVER}/users/auth/ldapmain/callback" --data "username=${GITLAB_USER}&password=${gitlabEncodedPassword}" --data-urlencode "authenticity_token=${csrf_token}" > /dev/null
        body_header=$(curl -k -L -H "Authorization: ${gitlab_basic_auth_string}" -H 'user-agent: curl' -b /tmp/cookies.txt -i "https://${GIT_SERVER}/profile/personal_access_tokens" -s) 
        csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p) 
        revoke=$(echo $body_header | perl -nle 'print join " ", m/personal_access_tokens\/(\d+)/g;') 
        if [ ! -z "$revoke" ]
        then
                for x in $revoke
                do
                        curl -k -s -o /dev/null -L -b /tmp/cookies.txt -X POST "https://${GIT_SERVER}/profile/personal_access_tokens/$x/revoke" --data-urlencode "authenticity_token=${csrf_token}" --data-urlencode "_method=put"
                done
        fi
        body_header=$(curl -k -s -L -H "Authorization: ${gitlab_basic_auth_string}" -b /tmp/cookies.txt "https://${GIT_SERVER}/profile/personal_access_tokens" \
                        --data-urlencode "authenticity_token=${csrf_token}" \
                        --data 'personal_access_token[name]='"${GITLAB_USER}"'&personal_access_token[expires_at]=&personal_access_token[scopes][]=api') 
        GITLAB_PAT=$(echo $body_header | perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' | sed -n 1p) 
        echo $GITLAB_PAT
}

gitlab_pat

export GITLAB_PAT

echo "********** Basic Settings"

echo export TEAM_NAME=$TEAM_NAME | tee -a ~/.bashrc -a ~/.zshrc
echo export USER_NAME=$USER_NAME | tee -a ~/.bashrc -a ~/.zshrc
echo export PASSWORD=$PASSWORD | tee -a ~/.bashrc -a ~/.zshrc
echo export CLUSTER_DOMAIN=$CLUSTER_DOMAIN | tee -a ~/.bashrc -a ~/.zshrc
echo export GIT_SERVER=$GIT_SERVER | tee -a ~/.bashrc -a ~/.zshrc
echo export GITLAB_USER=$GITLAB_USER | tee -a ~/.bashrc -a ~/.zshrc
echo export GITLAB_PAT=$GITLAB_PAT | tee -a ~/.bashrc -a ~/.zshrc

# Group作成
curl -k -X POST \
  -H "PRIVATE-TOKEN: ${GITLAB_PAT}" -H "Content-Type:application/json" \
  "https://${GIT_SERVER}/api/v4/groups/" -d "{\"path\": \"${TEAM_NAME}\", \"name\": \"${TEAM_NAME}\", \"visibility\": \"public\"}"

# Namespace ID取得
NAMESPACE_ID=$(curl -s -k -H "PRIVATE-TOKEN: ${GITLAB_PAT}" "https://${GIT_SERVER}/api/v4/namespaces/${TEAM_NAME}" | jq -r ".id")
echo $NAMESPACE_ID

# Git Repository作成
for REPO_NAME in tech-exercise pet-battle-api
do
curl -k -X POST \
  -H "PRIVATE-TOKEN: ${GITLAB_PAT}" -H "Content-Type:application/json" \
  "https://${GIT_SERVER}/api/v4/projects/" -d "{\"namespace_id\": \"${NAMESPACE_ID}\", \"name\": \"${REPO_NAME}\",\"visibility\": \"internal\"}"
done
  
source printbasic

echo "\ninstall-basic done"


