Rails.application.routes.draw do
  # コンテナ・ロードバランサ(ALB等)のヘルスチェック用。アプリが起動していれば 200 を返す
  # （SPA の catch-all より先に定義する必要がある）
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise のマッピング（warden の scope :account）だけ登録し、ルートは /api/v1 配下に自前で定義する
  devise_for :accounts, skip: :all

  namespace :api do
    namespace :v1 do
      # 認証
      resource :session, only: %i(show create destroy), controller: "sessions"
      resource :registration, only: %i(create update destroy), controller: "registrations"
      resource :password, only: %i(create update), controller: "passwords"

      # enum 定義などフロントエンドと共有するメタ情報
      get "meta", to: "meta#show"

      # 画像の二段階アップロード（blob 作成 → signed_id で添付確定。未確定分は DELETE で破棄）
      resources :uploads, only: %i(create destroy), param: :signed_id

      resources :posts, only: %i(index show create update destroy) do
        resource :favorite, only: %i(create destroy), controller: "favorites"
      end
      resources :accounts, only: %i(show update)

      namespace :admin do
        resources :accounts, only: %i(index destroy)
      end
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ビルド済み SPA（public/index.html）の配信。API・Active Storage・拡張子付きパスは除外する
  root "static#index"
  get "*path", to: "static#index", constraints: ->(req) {
    !req.path.start_with?("/api/", "/rails/", "/letter_opener") && !req.path.include?(".")
  }
end
