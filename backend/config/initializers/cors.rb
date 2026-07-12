# 通常の開発は Vite の proxy 経由（同一オリジン）なので CORS 設定は不要。
# SPA を別オリジンで配信する場合のみ CORS_ORIGINS を設定する。
# 例: CORS_ORIGINS=https://front.example.com,http://localhost:5173
if ENV["CORS_ORIGINS"].present?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*ENV["CORS_ORIGINS"].split(","))
      resource "*",
        headers: :any,
        methods: %i(get post put patch delete options head),
        credentials: true
    end
  end
end
