# ビルド済み SPA（public/index.html）を返すフォールバックコントローラ。
# 開発中は Vite の dev サーバ（http://localhost:5173）を使うため、通常ここは本番でのみ通る。
class StaticController < ApplicationController
  def index
    index_html = Rails.public_path.join("index.html")
    if index_html.exist?
      send_file index_html, type: "text/html; charset=utf-8", disposition: :inline
    else
      render json: {
        message: "フロントエンドのビルドが見つかりません。開発時は Vite（http://localhost:5173）へアクセスしてください。" \
                 "本番配信する場合は frontend/ で `npm run build` を実行してください。"
      }, status: :not_found
    end
  end
end
