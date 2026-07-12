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

    describe 'アイコンの設定・削除' do
      # uploads API 相当の未添付 blob（signed_id で添付を確定する前の状態）
      def create_upload_blob
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join('spec/fixtures/files/test.png')),
          filename: 'test.png',
          content_type: 'image/png'
        )
      end

      before { sign_in account }

      it 'アップロード済みの signed_id を渡すとアイコンを設定できる' do
        blob = create_upload_blob
        patch api_v1_account_path(account), params: { account: { portrait: blob.signed_id } }
        expect(response).to have_http_status(200)
        expect(account.reload.portrait).to be_attached
        expect(account.portrait.blob.id).to eq blob.id
        expect(response.parsed_body.dig('account', 'portrait_url')).to include '/rails/active_storage/'
      end

      it 'remove_portrait を渡すとアイコンを削除できる' do
        account.portrait.attach(create_upload_blob)
        patch api_v1_account_path(account), params: { account: { remove_portrait: true } }
        expect(response).to have_http_status(200)
        expect(account.reload.portrait).not_to be_attached
        expect(response.parsed_body.dig('account', 'portrait_url')).to be_nil
      end

      it '新しい portrait と remove_portrait を同時に渡した場合は新しいアイコンを優先する' do
        account.portrait.attach(create_upload_blob)
        new_blob = create_upload_blob
        patch api_v1_account_path(account), params: { account: { portrait: new_blob.signed_id, remove_portrait: true } }
        expect(response).to have_http_status(200)
        expect(account.reload.portrait).to be_attached
        expect(account.portrait.blob.id).to eq new_blob.id
      end

      it '不正な signed_id は 422 を返す' do
        patch api_v1_account_path(account), params: { account: { portrait: 'invalid-signed-id' } }
        expect(response).to have_http_status(422)
        expect(account.reload.portrait).not_to be_attached
      end
    end
  end
end
