module Api
  module V1
    module Admin
      # 管理者用アカウント管理（旧 RailsAdmin の代替）
      class AccountsController < BaseController
        before_action :require_signin!
        before_action :require_admin!

        def index
          accounts = Account.includes(:posts).order(created_at: :desc).page(params[:page]).per(50)
          render json: {
            accounts: accounts.map { |account| admin_json(account) },
            meta: pagination_meta(accounts)
          }
        end

        def destroy
          account = Account.find(params[:id])
          account.destroy!
          render json: { message: I18n.t("accounts.destroy.destroyed") }
        end

        private

        def admin_json(account)
          {
            id: account.id,
            name: account.name,
            nickname: account.nickname,
            email: account.email,
            region: account.region,
            admin: account.admin?,
            posts_count: account.posts.size,
            created_at: account.created_at.iso8601
          }
        end
      end
    end
  end
end
