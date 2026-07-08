require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let!(:account) { create(:second_account) } # password: "password"

  describe 'GET /api/v1/session' do
    context '未ログインの場合' do
      it 'account: null を返す' do
        get api_v1_session_path
        expect(response).to have_http_status(200)
        expect(response.parsed_body['account']).to be_nil
      end
    end

    context 'ログイン済みの場合' do
      it 'アカウント情報を返す' do
        sign_in account
        get api_v1_session_path
        expect(response).to have_http_status(200)
        expect(response.parsed_body['account']).to include(
          'id' => account.id,
          'name' => 'hanako',
          'email' => 'hanako@sample.com',
          'admin' => false
        )
      end
    end
  end

  describe 'POST /api/v1/session' do
    context '正しいメールアドレスとパスワードの場合' do
      it 'ログインできる' do
        post api_v1_session_path, params: { email: account.email, password: 'password' }
        expect(response).to have_http_status(201)
        expect(response.parsed_body['message']).to eq 'ログインしました'
        expect(response.parsed_body.dig('account', 'id')).to eq account.id

        get api_v1_session_path
        expect(response.parsed_body['account']).to be_present
      end
    end

    context 'パスワードが誤っている場合' do
      it '401 とエラーメッセージを返す' do
        post api_v1_session_path, params: { email: account.email, password: 'wrong-password' }
        expect(response).to have_http_status(401)
        expect(response.parsed_body['error']).to eq 'メールアドレスまたはパスワードに誤りがあります'
      end
    end

    context '存在しないメールアドレスの場合' do
      it '401 を返す' do
        post api_v1_session_path, params: { email: 'unknown@sample.com', password: 'password' }
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE /api/v1/session' do
    it 'ログアウトできる' do
      sign_in account
      delete api_v1_session_path
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'ログアウトしました'

      get api_v1_session_path
      expect(response.parsed_body['account']).to be_nil
    end
  end
end
