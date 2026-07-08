module Api
  module V1
    class RegistrationsController < BaseController
      before_action :require_signin!, only: %i(update destroy)

      # アカウント登録（登録後そのままログイン状態にする）
      def create
        account = Account.new(sign_up_params)
        if account.save
          sign_in(:account, account)
          render json: { account: AccountSerializer.session(account), message: I18n.t("accounts.create.created") }, status: :created
        else
          render_errors(account)
        end
      end

      # アカウント名・メールアドレス・パスワードの変更（現在のパスワードで本人確認）
      def update
        account = current_account
        if account.update_with_password(account_update_params)
          bypass_sign_in(account, scope: :account)
          render json: { account: AccountSerializer.session(account), message: I18n.t("devise.registrations.updated") }
        else
          render_errors(account)
        end
      end

      # アカウント削除（投稿・いいねも dependent: :destroy で削除される）
      def destroy
        current_account.destroy!
        sign_out(:account)
        render json: { message: I18n.t("accounts.destroy.destroyed") }
      end

      private

      def sign_up_params
        params.require(:account).permit(:name, :email, :nickname, :region, :self_introduction, :portrait, :password, :password_confirmation)
      end

      def account_update_params
        params.require(:account).permit(:name, :email, :password, :password_confirmation, :current_password)
      end
    end
  end
end
