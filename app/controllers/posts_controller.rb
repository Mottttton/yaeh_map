class PostsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_post, only: %i(show edit update destroy)
  before_action :correct_post_owner, only: %i(edit update destroy)

  def index
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(favorites: :favoritable, account: {portrait_attachment: :blob}).with_attached_photos.in_reverse_created_date_order.page(params[:page])
    if params[:q].nil? && current_account.region.present? # 検索していない かつ プロフィールに地域を設定している
      @posts = @posts.filter_by_region(current_account.region).or(@posts.filter_by_account_id(current_account.id)).page(params[:page]) # ログインアカウントの地域と自身の投稿を表示
    end # それ以外は全地域からフィルターをかける
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
    params.require(:post).permit(:title, :region, :prefecture, :description, :genre, :place, :latitude, :longitude, photos: [])
  end

  def correct_post_owner
    set_post
    redirect_to posts_path, notice: t('notice.reject') unless current_account.id == @post.account_id
  end
end
