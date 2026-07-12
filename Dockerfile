# syntax=docker/dockerfile:1
# 本番用イメージ（AWS ECS / GCP Cloud Run 等へのデプロイを想定）
#
# ビルド:
#   docker build --build-arg VITE_GOOGLE_MAPS_API_KEY=<APIキー> -t yaeh_map .
# 起動:
#   docker run -e RAILS_MASTER_KEY=<backend/config/master.keyの値> -e DATABASE_URL=<接続URL> -p 3000:3000 yaeh_map
#
# Puma は PORT 環境変数を読むため、Cloud Run のようにポートが注入される環境でもそのまま動く。

ARG RUBY_VERSION=3.4.4
ARG NODE_VERSION=22

# ---------------------------------------------------------------------------
# base: 実行にも使う共通レイヤー
# ---------------------------------------------------------------------------
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# 実行時に必要なパッケージ（libvips: image_processing / libpq5: pg / jemalloc: メモリ削減）
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1"

# ---------------------------------------------------------------------------
# build: gem のインストールと bootsnap の事前コンパイル
# ---------------------------------------------------------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY backend/Gemfile backend/Gemfile.lock backend/.ruby-version ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY backend/ .
RUN bundle exec bootsnap precompile app/ lib/

# ---------------------------------------------------------------------------
# frontend: Vue(Vite) の本番ビルド。backend/public/ に index.html と assets を出力する
# ---------------------------------------------------------------------------
FROM node:$NODE_VERSION-slim AS frontend

WORKDIR /app

COPY frontend/package.json frontend/package-lock.json ./frontend/
RUN npm ci --prefix frontend

# Vite はビルド時に VITE_* を埋め込むため、APIキーは build-arg で渡す
ARG VITE_GOOGLE_MAPS_API_KEY
ENV VITE_GOOGLE_MAPS_API_KEY=$VITE_GOOGLE_MAPS_API_KEY

# リポジトリと同じ frontend/ ↔ backend/public の相対配置を再現する（Vite の outDir は ../backend/public）
COPY backend/public ./backend/public
COPY frontend ./frontend
RUN npm run build --prefix frontend

# ---------------------------------------------------------------------------
# 最終イメージ
# ---------------------------------------------------------------------------
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails
COPY --from=frontend /app/backend/public /rails/public

# 非 root ユーザーで実行する
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
