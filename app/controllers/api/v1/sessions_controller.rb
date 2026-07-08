module Api
  module V1
    class SessionsController < BaseController
      # ログイン状態の確認（SPA 起動時に呼ばれる。未ログインでも 200 で account: null を返す）
      def show
        render json: { account: AccountSerializer.session(current_account) }
      end

      # ログイン
      def create
        account = Account.find_for_database_authentication(email: params[:email])
        if account&.valid_password?(params[:password])
          account.remember_me = ActiveModel::Type::Boolean.new.cast(params[:remember_me])
          sign_in(:account, account)
          render json: { account: AccountSerializer.session(account), message: I18n.t("sessions.create.created") }, status: :created
        else
          render json: { error: I18n.t("sessions.create.fail") }, status: :unauthorized
        end
      end

      # ログアウト
      def destroy
        sign_out(:account)
        render json: { message: I18n.t("sessions.destroy.destroyed") }
      end
    end
  end
end
