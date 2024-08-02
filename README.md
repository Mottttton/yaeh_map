# README
## 開発言語
- Ruby 3.0.1
- Rails 6.1.7.6
## インフラ
- AWS EC2 & S3
## アプリケーションURL
https://yaehmap.com
## ローカル環境での実行手順
### アプリのダウンロードと設定
~~~
$ git clone git@github.com:Mottttton/yaeh_map.git
$ cd yaeh_map
$ bundle install
$ yarn install
$ rails db:create && rails db:migrate
$ touch .env
$ echo GOOGLE_MAPS_API_KEY="YOUR_GOOGLE_MAPS_API_KEY" >> .env
~~~
### Google Maps APIの設定
1. Google Cloudプロジェクトをセットアップし、下記のAPIを有効にする
    - Maps JavaScript API
    - Maps Embed API
    - Geocoding API
    - Maps Static API

    (参考)[Google Cloudプロジェクトをセットアップする](https://developers.google.com/maps/documentation/javascript/cloud-setup?hl=ja&_gl=1*1h92l89*_up*MQ..*_ga*MTMwNjI0NDUyMy4xNzIyNTY4NDI5*_ga_NRWSTWS78N*MTcyMjU2ODQyOC4xLjAuMTcyMjU2ODQyOC4wLjAuMA..)
2. APIキーを作成し、.envファイルの"YOUR_GOOGLE_MAPS_API_KEY"と置き換える

    (参考)[APIキーを作成する](https://developers.google.com/maps/documentation/javascript/get-api-key?hl=ja&_gl=1*136gjer*_up*MQ..*_ga*MTMwNjI0NDUyMy4xNzIyNTY4NDI5*_ga_NRWSTWS78N*MTcyMjU2ODQyOC4xLjAuMTcyMjU2ODQyOC4wLjAuMA..)
### サーバの起動
~~~
rails s
~~~
### webpackの起動
rails sとは別にコマンドラインを起動して実行
~~~
bin/webpack-dev-server
~~~
## カタログ設計
https://docs.google.com/spreadsheets/d/1KLbQwRTSX5NL1LeW82SDRLgg-5pNCJA8RkDJHrcA0m8/edit?usp=sharing
## テーブル定義書
https://docs.google.com/spreadsheets/d/1xh__VsRgFcSfyQD3rAxc1OgfvTmXkjART9I91wb-JJg/edit?usp=sharing
## ER図
![ER図](/img/readme/er.png)
## 画面遷移図
![画面遷移図](/img/readme/screen_transition.png)