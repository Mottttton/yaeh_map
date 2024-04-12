class AccountsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_account, only: %i(show edit update)
  before_action :correct_account, only: %i(edit update)

  def show
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
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:nickname, :region, :self_introduction)
  end

  def correct_account
    @account = Account.find(params[:id])
    redirect_to posts_path, notice: t('notice.reject') unless current_account.id == @account.id
  end
end
