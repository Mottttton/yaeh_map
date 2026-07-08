module Api
  module V1
    class PasswordsController < BaseController
      # パスワード再設定メールの送信
      def create
        Account.send_reset_password_instructions(email: params[:email])
        # アカウントの存在有無を漏らさないよう、常に成功レスポンスを返す
        render json: { message: I18n.t("passwords.create.sent") }
      end

      # メールに記載したトークンでパスワードを再設定
      def update
        account = Account.reset_password_by_token(
          reset_password_token: params[:reset_password_token],
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        )
        if account.errors.empty?
          render json: { message: I18n.t("passwords.update.updated") }
        else
          render_errors(account)
        end
      end
    end
  end
end
