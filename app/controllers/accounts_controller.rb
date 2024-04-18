class AccountsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_account, only: %i(edit update)
  before_action :correct_account, only: %i(edit update)

  def show
    @account = Account.includes(posts: {photos_attachments: :blob}).with_attached_portrait.find(params[:id])
    @posts = @account.posts.includes(:favorites, {photos_attachments: :blob}).order(created_at: 'DESC').page(params[:page])
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to account_path(@account.id), notice: t('.updated')
    else
      render :edit
    end
  end

  private

  def set_account
    @account = Account.includes(:posts).with_attached_portrait.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:nickname, :region, :self_introduction, :portrait)
  end

  def correct_account
    @account = Account.find(params[:id])
    redirect_to posts_path, notice: t('notice.reject') unless current_account.id == @account.id
  end
end
