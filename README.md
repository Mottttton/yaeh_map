# README
## アーキテクチャ
Vue.js(SPA) + Ruby on Rails(APIモード) 構成

- バックエンド: Ruby on Rails 8.0(APIモード)。`/api/v1` 配下で JSON API を提供
- フロントエンド: Vue 3 + Vite + Pinia + Vue Router(`frontend/` ディレクトリ)
- 認証: Devise によるセッション Cookie 認証(CSRF トークンは Cookie 連携)
- 開発時は Vite の dev サーバが `/api` と `/rails`(画像配信)を Rails へ proxy する

## 開発言語
- Ruby 3.4.4
- Rails 8.0
- Vue 3 / Vite(Node.js 20 以上)
## データベース
- PostgreSQL
## インフラ
- AWS EC2 & S3
## アプリケーションURL
https://yaehmap.com
## ローカル環境での実行手順
### アプリのダウンロードと設定
~~~
$ git clone git@github.com:Mottttton/yaeh_map.git
$ cd yaeh_map
$ bin/setup
~~~
`bin/setup` は bundle install / npm install(frontend) / DB 作成までを行います。
サンプルデータが必要な場合は `bin/rails db:seed` を実行してください。
### Google Maps APIの設定
1. Google Cloudプロジェクトをセットアップし、下記のAPIを有効にする
    - Maps JavaScript API
    - Maps Embed API
    - Geocoding API
    - Maps Static API

    (参考)[Google Cloudプロジェクトをセットアップする](https://developers.google.com/maps/documentation/javascript/cloud-setup?hl=ja)
2. APIキーを作成し、`frontend/.env` に設定する

    ~~~
    $ cd frontend
    $ cp .env.example .env
    # .env の VITE_GOOGLE_MAPS_API_KEY にキーを設定
    ~~~

    (参考)[APIキーを作成する](https://developers.google.com/maps/documentation/javascript/get-api-key?hl=ja)

    ※APIキー未設定でも地図表示以外の機能は動作します(投稿の新規作成には位置情報の取得が必要なためキーが必要です)
### サーバの起動
~~~
$ bin/dev
~~~
Rails API(ポート3000)と Vite dev サーバ(ポート5173)が同時に起動します。
- アプリ本体: http://localhost:5173
- Rails API: http://localhost:3000/api/v1
- 送信メールの確認(開発環境): http://localhost:3000/letter_opener

ポート3000が使用中の場合は `API_PORT=3001 VITE_API_ORIGIN=http://localhost:3001 bin/dev` のように変更できます。
### テストの実行
~~~
$ bundle exec rspec
~~~
## Docker での開発・実行
### ローカル開発環境（docker compose）
db(PostgreSQL) / api(Rails) / web(Vite) / storage(RustFS) の4コンテナが起動します。ソースコードはマウントされるため、編集は即座に反映されます（Vite の HMR も有効）。
~~~
$ bin/docker-dev
~~~
`bin/docker-dev` はポート 3000 / 5173 が使用中の場合、**空いているポートを自動で選んで起動**します（起動時に URL が表示されます）。ポートを固定したい場合は環境変数で指定できます。
~~~
$ API_PORT=3001 WEB_PORT=5273 docker compose up
~~~
2セット同時に起動する場合はプロジェクト名も変えてください。
~~~
$ COMPOSE_PROJECT_NAME=yaeh_map2 bin/docker-dev
~~~
- PostgreSQL のポートはホストに公開していないため、ホスト側の PostgreSQL とは競合しません。DB へ直接入る場合: `docker compose exec db psql -U postgres yaeh_map_development`
- 画像等のアップロードは storage(RustFS, S3互換) に保存されます（本番の S3 相当）。バケットは api 起動時に `bin/rails storage:prepare` で自動作成され、配信は Rails の proxy 経由のためホストへのポート公開はありません
- テストの実行: `docker compose exec api bundle exec rspec`
- Gemfile 変更時: コンテナ再起動時に自動で `bundle install` されます（イメージを作り直す場合は `docker compose build api`）

### 本番用イメージ（AWS ECS / GCP デプロイ想定）
`Dockerfile` はマルチステージビルドで、Vue のビルド成果物（public/）を含む単一イメージを生成します。Rails(Puma) が API と SPA の両方を配信します。
~~~
$ docker build --build-arg VITE_GOOGLE_MAPS_API_KEY=<APIキー> -t yaeh_map .
~~~
実行時に必要な環境変数:
| 変数 | 説明 |
| --- | --- |
| RAILS_MASTER_KEY | `config/master.key` の値（または SECRET_KEY_BASE） |
| DATABASE_URL | DB 接続 URL（RDS / Cloud SQL 等）。または DATABASE_HOST / DATABASE_USER / DATABASE_PASSWORD |
| PORT | 待受ポート（省略時 3000。Cloud Run では自動注入される） |
| ACTIVE_STORAGE_SERVICE | `amazon` を指定すると S3 に保存（ECS 等ではコンテナが揮発するため必須）。あわせて AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY を設定 |
| AUTO_DB_PREPARE | `false` でサーバ起動時の自動マイグレーションを無効化（マイグレーションを別タスクで実行する場合） |

ヘルスチェックは `GET /up` を使用してください（ALB / Cloud Run 対応）。

本番イメージをローカルで動作確認する場合:
~~~
$ RAILS_MASTER_KEY="$(cat config/master.key)" docker compose -f compose.production.yaml up --build
# http://localhost:8080 で確認（APP_PORT で変更可）
~~~
### 本番用ビルド
~~~
$ cd frontend && npm run build
~~~
ビルド結果は `public/` に出力され、Rails(または Nginx)がそのまま配信できます。
SPA のルーティングは Rails 側の catch-all ルートが `public/index.html` を返すことで動作します。
### 管理者
`Account` の `admin` フラグが true のアカウントは、ナビゲーションの「管理者用」(/admin)からアカウント管理画面を利用でき、全ての投稿を削除できます。
~~~
$ bin/rails runner 'Account.find_by(name: "アカウント名").update!(admin: true)'
~~~
## 主なAPIエンドポイント
| メソッド | パス | 説明 |
| --- | --- | --- |
| GET/POST/DELETE | /api/v1/session | ログイン状態取得・ログイン・ログアウト |
| POST/PATCH/DELETE | /api/v1/registration | アカウント登録・認証情報変更・退会 |
| POST/PATCH | /api/v1/password | パスワード再設定メール送信・再設定 |
| GET/POST | /api/v1/posts | 投稿一覧(Ransack検索・ページネーション)・投稿作成 |
| GET/PATCH/DELETE | /api/v1/posts/:id | 投稿詳細・更新・削除 |
| POST/DELETE | /api/v1/posts/:post_id/favorite | いいね登録・解除 |
| GET/PATCH | /api/v1/accounts/:id | プロフィール表示・更新 |
| GET/DELETE | /api/v1/admin/accounts(/:id) | 管理者用アカウント一覧・削除 |
| GET | /api/v1/meta | enum定義(地域・都道府県・分類)の取得 |
## デプロイに関する注意
旧構成(Capistrano + Unicorn + Webpacker)のデプロイ設定はリアーキテクチャに伴い削除しました(履歴は git に残っています)。新構成では「Rails API(Puma) + ビルド済み SPA(public/)を Nginx 等で配信」する形を想定しており、デプロイフローの再構築が必要です。
## カタログ設計
https://docs.google.com/spreadsheets/d/1KLbQwRTSX5NL1LeW82SDRLgg-5pNCJA8RkDJHrcA0m8/edit?usp=sharing
## テーブル定義書
https://docs.google.com/spreadsheets/d/1xh__VsRgFcSfyQD3rAxc1OgfvTmXkjART9I91wb-JJg/edit?usp=sharing
## ER図
![ER図](/img/readme/er.png)
## 画面遷移図
![画面遷移図](/img/readme/screen_transition.png)
