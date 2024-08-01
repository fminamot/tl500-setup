# BUILD_CONTAINER.md

## コンテナーアプリのビルド準備

1. Google Docsの技術演習手順書からHTMLファイルを生成
2. 生成されたHTMLファイルをcontainers/app-srcディレクトリにコピー

## コンテナーアプリのビルド手順

1. podman build -t tl500 .

## ローカルでの実行方法 (公開ポート番号を8082にした場合)

podman run --rm --name tl500 -d -p 8082:8080 local/tl500

## コンテナーイメージのquay.ioへのプッシュ

イメージタグは、もとのドキュメントのリビジョンに合わせて設定する。

1. podman tag localhost/tl500 quay.io/minamot/tl500:latest
2. podman push quay.io/minamot/tl500:latest

## quay.ioからの実行方法 (公開ポート番号を8082にした場合)
podman run --rm --name tl500 -d -p 8082:8080 quay.io/minamot/tl500:latest

### OpenShiftへのインストール
oc login -u admin -p <password> https://api.ocp4.example.com:6443
oc new-app --name tl500-docs-ja --image quay.io/minamot/tl500:latest

アクセスURL
https://tl500-docs-ja-tl500-tech-exercise.apps.ocp4.example.com
