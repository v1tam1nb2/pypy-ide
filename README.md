# pypy-ide

PyPy検証環境。


## Python モジュール

以下のテキストファイルに必要なモジュールを箇条書きで適宜記載してください。"#"はコメントアウトを意味し、無視されます。

```shell
./src/common/python/requirements/common.txt
```
## ビルド

Dockerfileがあるディレクトリで以下を実行する。

```shell
docker build -t pypy-ide:0.0.1 .
```

プロキシ環境下でビルドする場合は```--build-args```でプロキシ環境変数を指定してください。
プロキシの情報が以下の場合のビルドコマンドを示します。

```shell
http_proxy="http://your-proxy-host:your-proxy-port"
no_proxy="127.0.1.1,localhost"
```

```shell
docker build -t pypy-ide:0.0.1 --build-arg http_proxy="http://your-proxy-host:your-proxy-port" --build-arg no_proxy="127.0.0.1,localhost" .
```

## docker hub へ push

- [yuimaijds/pypy-ide](https://hub.docker.com/r/yuimaijds/pypy-ide)

```
docker login
docker tag pypy-ide:0.0.1 yuimaijds/pypy-ide:0.0.1
docker push yuimaijds/pypy-ide:0.0.1
```

## 起動準備

本サービスではコンテナの80番ポートの公開が前提としています。
コンテナの80番ポートをホストの8080番に割り当てる場合の```docker-compose.yaml```の設定は以下の通りです。
すでに8080番ポートを利用している場合は、適宜変更してください。

```yaml
    # ポートフォワードの設定
    ports:
      - '8080:80'
```

## コンテナの起動

```docker-compose.yaml```を配置しているディレクトリで以下を実行してください。

```shell
docker-compose up -d
```

## アクセス

8080番ポートでコンテナを起動した場合は、以下にアクセスしてください。

- <b>Top ページ</b>
    - [http://localhost:8080/top/](http://localhost:8080/top/)
- <b>code-server</b>
    - [http://localhost:8080/code/?folder=/workspace](http://localhost:8080/code/?folder=/workspace)
- <b>Fastapi（起動している場合）</b>
    - [http://localhost:8080/fastapi/](http://localhost:8080/fastapi/)
