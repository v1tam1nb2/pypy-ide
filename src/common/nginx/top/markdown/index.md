# Topページ

## 利用できるサービス

8080ポートで起動している場合は以下のようにサービスにアクセスできます。

- **code-server**
    - [http://localhost:8080/code/?folder=/workspace](http://localhost:8080/code/?folder=/workspace)
- **FasAPI（起動している場合どちらでも可）**
    - [http://localhost:8080/](http://localhost:8080/)
    - [http://localhost:8080/fastapi/](http://localhost:8080/fastapi/)
## 注意点

**コンテナ以内の /workspace フォルダのみ永続化をしています。それ以外のディレクトリにデータを保存しても永続化されません。**
