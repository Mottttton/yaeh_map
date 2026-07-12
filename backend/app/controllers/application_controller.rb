class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  # SPA からの Cookie セッション認証のため CSRF 保護を有効にする。
  # トークンを Cookie で払い出し、フロントエンドは X-CSRF-Token ヘッダで送り返す。
  # API モードでは config.action_controller.allow_forgery_protection が
  # 自動では反映されないため明示的に設定する（test 環境では無効になる）。
  self.allow_forgery_protection = Rails.application.config.action_controller.allow_forgery_protection != false
  protect_from_forgery with: :exception
  after_action :set_csrf_cookie

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "リソースが見つかりません" }, status: :not_found
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    render json: { error: "セッションが無効です。ページを再読み込みしてください" }, status: :unprocessable_entity
  end

  private

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = { value: form_authenticity_token, same_site: :lax }
  end
end
