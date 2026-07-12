module Api
  module V1
    class AccountsController < BaseController
      before_action :require_signin!

      # プロフィールと投稿一覧
      def show
        account = Account.with_attached_portrait.find(params[:id])
        posts = account.posts
                       .includes(:favorites, account: { portrait_attachment: :blob })
                       .with_attached_photos
                       .in_reverse_created_date_order
                       .page(params[:page])
        render json: {
          account: AccountSerializer.profile(account),
          posts: posts.map { |post| PostSerializer.card(post, current_account: current_account) },
          meta: pagination_meta(posts)
        }
      end

      # プロフィール更新（本人のみ）
      def update
        account = Account.find(params[:id])
        return render json: { error: I18n.t("notice.reject") }, status: :forbidden unless account.id == current_account.id

        if account.update(account_params)
          render json: { account: AccountSerializer.profile(account), message: I18n.t("accounts.update.updated") }
        else
          render_errors(account)
        end
      end

      private

      def account_params
        params.require(:account).permit(:nickname, :region, :self_introduction, :portrait)
      end
    end
  end
end
