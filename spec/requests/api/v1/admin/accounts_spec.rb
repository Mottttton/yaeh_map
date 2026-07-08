require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Accounts', type: :request do
  let!(:admin) { create(:first_account) }        # admin: true
  let!(:account) { create(:second_account) }     # admin: false

  describe 'GET /api/v1/admin/accounts' do
    it '管理者はアカウント一覧を取得できる' do
      sign_in admin
      get api_v1_admin_accounts_path
      expect(response).to have_http_status(200)
      accounts = response.parsed_body['accounts']
      expect(accounts.size).to eq 2
      expect(accounts.map { |a| a['name'] }).to contain_exactly('taro', 'hanako')
      expect(accounts.first).to have_key('email')
      expect(accounts.first).to have_key('posts_count')
    end

    it '一般アカウントは 403 を返す' do
      sign_in account
      get api_v1_admin_accounts_path
      expect(response).to have_http_status(403)
      expect(response.parsed_body['error']).to eq 'アクセス権限がありません'
    end

    it '未ログインは 401 を返す' do
      get api_v1_admin_accounts_path
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /api/v1/admin/accounts/:id' do
    it '管理者はアカウントを削除できる' do
      sign_in admin
      expect {
        delete api_v1_admin_account_path(account)
      }.to change(Account, :count).by(-1)
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'アカウントを削除しました'
    end

    it '一般アカウントは削除できない' do
      sign_in account
      expect {
        delete api_v1_admin_account_path(admin)
      }.not_to change(Account, :count)
      expect(response).to have_http_status(403)
    end
  end
end
