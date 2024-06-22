# PetBattle APIをローカルで実行する方法。

## 0. 準備
java 11とmavenをインストール
```
$ sudo dnf install java-11-openjdk
$ sudo dnf install maven
```

## 1. PetBattle apiをclone
```
$ git clone https://github.com/rht-labs/pet-battle-api
```
## 2. mongodb起動
```
$ podman run --name mongo -p 27017:27017 docker.io/mongo:latest
```
## 3. petbattle apiコンパイル&起動
```
$ mvn compile quarkus:dev
```

## 4. petbattle api UI

Webブラウザで http://localhost:8080 を開く

