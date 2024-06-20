# README

## INSTRUCTIONS

### 1. basicファイルを編集

```
# 実際に払い出された各種情報をここに設定する
export USER_NAME=user1
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
$ echo "https://${GITLAB_SERVER}"
```

* ブラウザからGitLabのURLを開く
* team1のpublicグループ作成する
* tech-exerciseという新規internalプロジェクトを作成する

### 4. 環境変数とGITLAB_PATの設定

```
$ ./install-basic.sh
```

### 5. ArgoCDとUbiquitous-journeyのインストール

```
$ ./install-uj.sh
```

### 6. Nexus, Keycloak, PetBattleのインストール

```
$ ./install-uj2.sh
```
* WebコンソールでDeveloper Perspective> Topologyに移動し、 <TEAM_NAME>-testプロジェクトの pet-battle を確認

### 7. GitLabでpet-battle-apiプロジェクト作成

* GitLabでteam1グループの下にpet-battle-apiという名前のinternalプロジェクトを作成

### 8. Tektonのインストール

```
$ ./install-tekton.sh
```

### 8. SonarQubeのインストール

```
$ ./install-sonarqube.sh
```

