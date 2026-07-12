require 'rails_helper'

RSpec.describe 'Api::V1::Passwords', type: :request do
  let!(:account) { create(:second_account) }

  describe 'POST /api/v1/password（再設定メール送信）' do
    it '登録済みメールアドレスなら再設定メールを送信する' do
      expect {
        post api_v1_password_path, params: { email: account.email }
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'パスワード再設定用のメールを送信しました'

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq [account.email]
      expect(mail.body.encoded).to include '/password/reset?reset_password_token='
    end

    it '未登録メールアドレスでも成功レスポンスを返す（存在の有無を漏らさない）' do
      expect {
        post api_v1_password_path, params: { email: 'unknown@sample.com' }
      }.not_to change { ActionMailer::Base.deliveries.size }
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /api/v1/password（トークンで再設定）' do
    it '有効なトークンでパスワードを変更できる' do
      token = account.send_reset_password_instructions
      patch api_v1_password_path, params: {
        reset_password_token: token, password: 'newpassword', password_confirmation: 'newpassword'
      }
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'パスワードを変更しました'
      expect(account.reload.valid_password?('newpassword')).to be true
    end

    it '不正なトークンは 422 を返す' do
      patch api_v1_password_path, params: {
        reset_password_token: 'invalid-token', password: 'newpassword', password_confirmation: 'newpassword'
      }
      expect(response).to have_http_status(422)
      expect(account.reload.valid_password?('password')).to be true
    end
  end
end
