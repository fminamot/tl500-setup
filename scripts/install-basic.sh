#!/bin/zsh

print_vars () {
        echo "TEAM_NAME=$TEAM_NAME"
        echo "USER_NAME=$USER_NAME"
        echo "PASSWORD=$PASSWORD"
        echo "CLUSTER_DOMAIN=$CLUSTER_DOMAIN"
        echo "GIT_SERVER=$GIT_SERVER"
        echo "GITLAB_USER=$GITLAB_USER"
        echo "GITLAB_PAT=$GITLAB_PAT"
}

export_vars () {
        echo export TEAM_NAME=$TEAM_NAME | tee -a ~/.bashrc -a ~/.zshrc
        echo export USER_NAME=$USER_NAME | tee -a ~/.bashrc -a ~/.zshrc
        echo export PASSWORD=$PASSWORD | tee -a ~/.bashrc -a ~/.zshrc
        echo export CLUSTER_DOMAIN=$CLUSTER_DOMAIN | tee -a ~/.bashrc -a ~/.zshrc
        echo export GIT_SERVER=$GIT_SERVER | tee -a ~/.bashrc -a ~/.zshrc
        echo export GITLAB_USER=$GITLAB_USER | tee -a ~/.bashrc -a ~/.zshrc
        echo export GITLAB_PAT=$GITLAB_PAT | tee -a ~/.bashrc -a ~/.zshrc
}

create_repos () {
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

}

export_vars
create_repos
print_vars

echo "install-basic done"


