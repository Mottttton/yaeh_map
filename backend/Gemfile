source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

# バックエンド本体（API モード）
gem 'rails', '~> 8.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'
# Use Puma as the app server
gem 'puma', '>= 6.4'

# 認証
gem 'devise'
gem 'devise-i18n'

# 検索・ページネーション
gem 'ransack'
gem 'kaminari'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'
gem 'active_storage_validations'
gem 'aws-sdk-s3', require: false

# 別オリジンから API を利用する場合の CORS 設定（通常は Vite の proxy 経由なので未使用）
gem 'rack-cors'

gem 'dotenv-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  gem 'debug', platforms: %i[mri], require: 'debug/prelude'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'letter_opener_web'
end
