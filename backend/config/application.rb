require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YaehMap
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    # Vue.js SPA のバックエンドとして API モードで動かす
    config.api_only = true

    # Devise のセッション Cookie 認証を使うため、API モードでも Cookie / Session ミドルウェアを有効化する
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_yaeh_map_session", same_site: :lax

    # 画像 URL をリダイレクトではなく Rails 経由のプロキシで配信する
    # （SPA から常に同一オリジンのパスで扱えるようにするため）
    config.active_storage.resolve_model_to_route = :rails_storage_proxy
    # 開発・本番のコンテナイメージ（Dockerfile / Dockerfile.dev）は libvips を同梱している
    # （ImageMagick は入っていないため :mini_magick にはしないこと）
    config.active_storage.variant_processor = :vips

    config.time_zone = "Asia/Tokyo"
    config.i18n.default_locale = :ja
    config.active_model.i18n_customize_full_message = true

    config.generators do |g|
      g.test_framework :rspec,
        model_specs: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: true
    end
  end
end
