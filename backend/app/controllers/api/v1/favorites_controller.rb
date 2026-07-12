module Api
  module V1
    class FavoritesController < BaseController
      before_action :require_signin!
      before_action :set_post

      def create
        favorite = current_account.favorites.build(favoritable: @post)
        if favorite.save
          render_favorite_state(status: :created)
        else
          render_errors(favorite)
        end
      end

      def destroy
        @post.favorites.find_by(account_id: current_account.id)&.destroy!
        render_favorite_state
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def render_favorite_state(status: :ok)
        render json: {
          post_id: @post.id,
          favorites_count: @post.favorites.count,
          favorited: @post.favorites.exists?(account_id: current_account.id)
        }, status: status
      end
    end
  end
end
