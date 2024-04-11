class AccountsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_account, only: [:show]

  def show
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
