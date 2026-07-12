module Api
  module V1
    class PostsController < BaseController
      before_action :require_signin!
      before_action :set_post, only: %i(show update destroy)
      before_action :require_owner_or_admin!, only: %i(update destroy)

      def index
        q = Post.ransack(params[:q])
        posts = q.result(distinct: true)
                 .includes(:favorites, account: { portrait_attachment: :blob })
                 .with_attached_photos
                 .in_reverse_created_date_order
        if params[:q].blank? && current_account.region.present?
          # 検索していない かつ プロフィールに地域を設定している場合は、
          # ログインアカウントの地域の投稿と自身の投稿を表示する
          posts = posts.filter_by_region(current_account.region).or(posts.filter_by_account_id(current_account.id))
        end
        posts = posts.page(params[:page])
        render json: { posts: serialize_posts(posts), meta: pagination_meta(posts) }
      end

      def show
        render json: { post: PostSerializer.card(@post, current_account: current_account) }
      end

      def create
        post = current_account.posts.build(post_params)
        if post.save
          render json: { post: PostSerializer.card(post, current_account: current_account), message: I18n.t("posts.create.created") }, status: :created
        else
          render_errors(post)
        end
      end

      def update
        if @post.update(post_params)
          render json: { post: PostSerializer.card(@post, current_account: current_account), message: I18n.t("posts.update.updated") }
        else
          render_errors(@post)
        end
      end

      def destroy
        @post.destroy!
        render json: { message: I18n.t("posts.destroy.destroyed") }
      end

      private

      def serialize_posts(posts)
        posts.map { |post| PostSerializer.card(post, current_account: current_account) }
      end

      def set_post
        @post = Post.find(params[:id])
      end

      # 写真は uploads API が払い出した signed_id の配列（photo_signed_ids）で受け取る。
      # 全量置き換えのため、編集時は残す既存写真の signed_id も含めて送る（含めなかった写真は削除される）
      def post_params
        permitted = params.require(:post).permit(:title, :region, :prefecture, :description, :genre, :place, :latitude, :longitude, photo_signed_ids: [])
        permitted[:photos] = permitted.delete(:photo_signed_ids) if permitted.key?(:photo_signed_ids)
        permitted
      end

      # 投稿の編集・削除は投稿者本人か管理者のみ
      def require_owner_or_admin!
        return if current_account.id == @post.account_id || current_account.admin?

        render json: { error: I18n.t("notice.reject") }, status: :forbidden
      end
    end
  end
end
