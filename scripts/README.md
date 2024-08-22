# README

## INSTRUCTIONS

### 1. basicファイルを編集

```
# 実際に払い出された各種情報をここに設定する
export USER_NAME=lab01
export PASSWORD=
export TEAM_NAME=team1
export CLUSTER_DOMAIN=
export GIT_SERVER="gitlab-ce.${CLUSTER_DOMAIN}"
export GITLAB_USER=${USER_NAME}
export GITLAB_PASSWORD=${PASSWORD}
```

### 2. WebコンソールでGitLab Podが起動していることを確認

* Admin Perspectiveを選択
* Home > Project において tl500-gitlab を選択
* Workload > Podを選択
* すべての Pod が Running であることを確認

### 3. GitLabでtech-exerciseプロジェクト作成

* TerminalでGitLabサーバーのURLを表示

```
$ source basic
$ echo "https://${GIT_SERVER}"
```

* ブラウザからGitLabのURLを開く


### 4. 環境変数の設定とGitLabプロジェクトの作成

```
$ ./install-basic.sh
$ source ~/.zshrc
```

このスクリプトによって、publicな teamX グループを作成し、そのグループの下に2つの internal プロジェクトを作成する。
GitLab UI上で、実際に作成されていることを確認する。

* tech-exercise
* pet-battle-api


### 5. ArgoCDとUbiquitous-journeyのインストール

```
$ ./install-uj.sh
```

### 6. GitLabのtech-exerciseプロジェクトにWebHook追加されていることを確認

* WebHook追加 (tech-exerciseプロジェクトのSettings>Integrations)

```
echo https://$(oc get route argocd-server --template='{{ .spec.host }}'/api/webhook  -n ${TEAM_NAME}-ci-cd)
```

### 7. Nexus, Keycloak, PetBattleのインストール

```
$ ./install-uj2.sh
```
* WebコンソールでDeveloper Perspective> Topologyに移動し、 <TEAM_NAME>-testプロジェクトの pet-battle を確認


### 8. Tektonのインストール

```
$ ./install-tekton.sh
```

### 9. GitLabのpet-battle-apiプロジェクトにWebHookが追加されていることを確認

* WebHook追加 (pet-battle-apiプロジェクトのSettings>Integrations)
```
echo https://$(oc -n ${TEAM_NAME}-ci-cd get route webhook --template='{{ .spec.host }}')
```

### 10. pet-battle-apiプロジェクトのWebHookを使ってPipelineを起動し、パイプラインが完了することを確認する

### 11. SonarQubeのインストール (TODO: シェルスクリプトにする)

*. /install-sonarqube.txtの手順に従ってSonarQubeをデプロイする

#### 12. デプロイ状況の確認

```
./show-consoles.sh
```

```
./watch-ci-cd.sh
```



