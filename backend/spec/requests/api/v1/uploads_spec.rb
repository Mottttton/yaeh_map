require 'rails_helper'

RSpec.describe 'Api::V1::Uploads', type: :request do
  let!(:account) { create(:second_account) }
  let(:png_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.png'), 'image/png') }

  describe 'POST /api/v1/uploads' do
    it '未ログインは 401 を返す' do
      post api_v1_uploads_path, params: { file: png_file }
      expect(response).to have_http_status(401)
    end

    context 'ログイン済みの場合' do
      before { sign_in account }

      it '画像をアップロードすると未添付の blob が作成され signed_id とプレビュー URL を返す' do
        expect {
          post api_v1_uploads_path, params: { file: png_file }
        }.to change(ActiveStorage::Blob, :count).by(1)
        expect(response).to have_http_status(201)

        blob = ActiveStorage::Blob.last
        expect(blob.attachments).to be_empty
        expect(response.parsed_body['signed_id']).to eq blob.signed_id
        expect(response.parsed_body['url']).to include '/rails/active_storage/'
      end

      it '画像以外のファイルは 422 を返す' do
        text_file = Rack::Test::UploadedFile.new(StringIO.new('plain text'), 'text/plain', original_filename: 'test.txt')
        post api_v1_uploads_path, params: { file: text_file }
        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include '画像はPNGまたはJPEG形式のみアップロードできます'
      end

      it 'サイズ上限(10MB)を超えるファイルは 422 を返す' do
        big_file = Rack::Test::UploadedFile.new(StringIO.new('0' * (10.megabytes + 1)), 'image/png', original_filename: 'big.png')
        post api_v1_uploads_path, params: { file: big_file }
        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include 'ファイルサイズは10MB以下にしてください'
      end
    end
  end

  describe 'DELETE /api/v1/uploads/:signed_id' do
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join('spec/fixtures/files/test.png')),
        filename: 'test.png',
        content_type: 'image/png'
      )
    end

    before { sign_in account }

    it '未添付の blob を削除できる' do
      signed_id = blob.signed_id
      expect {
        delete api_v1_upload_path(signed_id)
      }.to change(ActiveStorage::Blob, :count).by(-1)
      expect(response).to have_http_status(204)
    end

    it '添付済みの blob は削除できない（422）' do
      account.portrait.attach(blob)
      expect {
        delete api_v1_upload_path(blob.signed_id)
      }.not_to change(ActiveStorage::Blob, :count)
      expect(response).to have_http_status(422)
    end

    it '不正な signed_id は 404 を返す' do
      delete api_v1_upload_path('invalid-signed-id')
      expect(response).to have_http_status(404)
    end
  end
end
