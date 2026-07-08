require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /api/v1/registration（アカウント登録）' do
    let(:valid_params) do
      { account: { name: 'taro', email: 'taro@sample.com', nickname: 'タロウ', region: '関東',
                   password: 'password', password_confirmation: 'password' } }
    end

    it '登録してそのままログイン状態になる' do
      expect {
        post api_v1_registration_path, params: valid_params
      }.to change(Account, :count).by(1)
      expect(response).to have_http_status(201)
      expect(response.parsed_body['message']).to eq 'アカウントを登録しました'
      expect(response.parsed_body.dig('account', 'name')).to eq 'taro'

      get api_v1_session_path
      expect(response.parsed_body['account']).to be_present
    end

    it 'バリデーションエラー時は 422 とエラーメッセージを返す' do
      post api_v1_registration_path, params: { account: { name: '', email: '', nickname: '', password: 'password', password_confirmation: 'password' } }
      expect(response).to have_http_status(422)
      expect(response.parsed_body['errors']).to include 'アカウント名を入力してください'
    end
  end

  describe 'PATCH /api/v1/registration（アカウント情報変更）' do
    let!(:account) { create(:second_account) }

    it '現在のパスワードで本人確認して変更できる' do
      sign_in account
      patch api_v1_registration_path, params: {
        account: { name: 'hanako_new', email: 'hanako_new@sample.com', password: '', password_confirmation: '', current_password: 'password' }
      }
      expect(response).to have_http_status(200)
      expect(account.reload.name).to eq 'hanako_new'
      expect(account.email).to eq 'hanako_new@sample.com'
    end

    it 'パスワードも変更できる' do
      sign_in account
      patch api_v1_registration_path, params: {
        account: { name: account.name, email: account.email, password: 'newpassword', password_confirmation: 'newpassword', current_password: 'password' }
      }
      expect(response).to have_http_status(200)
      expect(account.reload.valid_password?('newpassword')).to be true
    end

    it '現在のパスワードが誤っていると 422 を返す' do
      sign_in account
      patch api_v1_registration_path, params: {
        account: { name: 'hanako_new', email: account.email, current_password: 'wrong-password' }
      }
      expect(response).to have_http_status(422)
      expect(account.reload.name).to eq 'hanako'
    end

    it '未ログインは 401 を返す' do
      patch api_v1_registration_path, params: { account: { name: 'x', current_password: 'password' } }
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /api/v1/registration（アカウント削除）' do
    let!(:account) { create(:second_account, :with_posts) }

    it 'アカウントと投稿を削除する' do
      sign_in account
      expect {
        delete api_v1_registration_path
      }.to change(Account, :count).by(-1).and change(Post, :count).by(-1)
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'アカウントを削除しました'
    end
  end
end
