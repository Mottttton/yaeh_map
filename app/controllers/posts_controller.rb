class PostsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_post, only: %i(show edit update destroy)
  before_action :correct_post_owner, only: %i(edit update destroy)

  def index
    @posts = Post.all.in_reverse_created_date_order
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_account.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: t('.created')
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post.id), notice: t('.updated')
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: t('.destroyed')
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :region, :prefecture, :description, :genre, :place_id)
  end

  def correct_post_owner
    set_post
    redirect_to posts_path, notice: t('notice.reject') unless current_account.id == @post.account_id
  end
end
