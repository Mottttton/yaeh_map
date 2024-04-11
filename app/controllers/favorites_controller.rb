class FavoritesController < ApplicationController
  before_action :set_post

  def create
    @favorite = current_account.favorites.new
    @post.favorites << @favorite
    respond_to do |format|
      format.js { render :favorite }
    end
  end

  def destroy
    @favorite = @post.favorites.find_by(account_id: current_account.id)
      @favorite.destroy!
      respond_to do |format|
        format.js { render :favorite }
      end
  end

  private

  def favorite_params
    params.require(:favorite).permit(:post_id)
  end

  def set_post
    @post = Post.find(params[:post_id])
  end
end
