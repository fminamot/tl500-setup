# README

演習環境にC-CDパイプラインをインストールする手順の概要を記す。
詳細な手順は [1] を参照のこと。

## INSTRUCTIONS

### 1. OCPの起動確認

utilityサーバーにsshでログインして、./wait.shスクリプトを実行し、
OCPの起動が完了していることを確認する。

```
ssh lab@utility
./wait.sh
```

### 2. Worksationのネットワーク設定

TL500 Instructor Guide[2] に従って、受講者のWorksationとOCPを接続する。


### 3. インストールスクリプトの複製

受講者のWorksationのターミナルからインストールスクリプトを実行する
以下のコマンドを実行して、インストールスクリプトを利用できるようにする。

```
git clone https://github.com/fminamot/tl500-setup.git
cd tl500-setup/scripts
chmod u+x *.sh
```

### 4. basicファイルを編集

USER_NAME, PASSWORD, TEAM_NAMEを修正する。

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

### 5. インストールスクリプトの実行

```
./install-all.sh
```

### 6. パイプラインの実行確認

```
./watch-ci-cd.sh
```

## References

* [1] TL500技術演習環境事前準備 (Google Docs)
* [2] TL500-Instructor-Guide-2023022210.pdf




