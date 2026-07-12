require 'rails_helper'

RSpec.describe 'Api::V1::Accounts', type: :request do
  let!(:account) { create(:second_account, :with_posts) }
  let!(:other_account) { create(:no_region_account) }

  describe 'GET /api/v1/accounts/:id' do
    it 'プロフィールと投稿一覧を返す' do
      sign_in other_account
      get api_v1_account_path(account)
      expect(response).to have_http_status(200)
      expect(response.parsed_body['account']).to include(
        'id' => account.id,
        'name' => 'hanako',
        'nickname' => 'hanako',
        'region' => '近畿'
      )
      # メールアドレスなどの認証情報は含まない
      expect(response.parsed_body['account']).not_to have_key('email')
      expect(response.parsed_body['posts'].size).to eq 1
      expect(response.parsed_body['meta']).to include('current_page' => 1)
    end

    it '未ログインは 401 を返す' do
      get api_v1_account_path(account)
      expect(response).to have_http_status(401)
    end
  end

  describe 'PATCH /api/v1/accounts/:id' do
    it '本人はプロフィールを更新できる' do
      sign_in account
      patch api_v1_account_path(account), params: {
        account: { nickname: '新ニックネーム', region: '関東', self_introduction: 'よろしくお願いします' }
      }
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq 'プロフィールを更新しました'
      expect(account.reload.nickname).to eq '新ニックネーム'
      expect(account.region).to eq '関東'
    end

    it '他人のプロフィールは更新できない（403）' do
      sign_in other_account
      patch api_v1_account_path(account), params: { account: { nickname: '乗っ取り' } }
      expect(response).to have_http_status(403)
      expect(account.reload.nickname).to eq 'hanako'
    end

    it 'バリデーションエラー時は 422 を返す' do
      sign_in account
      patch api_v1_account_path(account), params: { account: { nickname: '' } }
      expect(response).to have_http_status(422)
      expect(response.parsed_body['errors']).to include 'ニックネームを入力してください'
    end
  end
end
