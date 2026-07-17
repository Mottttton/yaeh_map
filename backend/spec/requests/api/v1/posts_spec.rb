require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let!(:admin) { create(:first_account) }            # region: 近畿(5), admin: true
  let!(:account) { create(:second_account) }         # region: 近畿(5), admin: false
  let!(:no_region_account) { create(:no_region_account) } # region 未設定

  # uploads API 相当の未添付 blob を作成する（photo_signed_ids で添付を確定する前の状態）
  def create_upload_blob
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec/fixtures/files/test.png')),
      filename: 'test.png',
      content_type: 'image/png'
    )
  end

  describe 'GET /api/v1/posts' do
    it '未ログインは 401 を返す' do
      get api_v1_posts_path
      expect(response).to have_http_status(401)
      expect(response.parsed_body['error']).to eq 'ログインしてください'
    end

    context 'ログイン済み（地域設定あり）の場合' do
      before { sign_in account }

      it '検索なしでは自分の地域の投稿と自身の投稿のみ返す' do
        kinki_post = create(:third_post, account: admin)      # 近畿(5)
        tokai_post = create(:second_post, account: admin)     # 東海(4) → 対象外
        own_post = create(:first_post, account: account)      # 東海(4) だが自身の投稿

        get api_v1_posts_path
        expect(response).to have_http_status(200)
        ids = response.parsed_body['posts'].map { |post| post['id'] }
        expect(ids).to contain_exactly(kinki_post.id, own_post.id)
      end

      it '投稿カードに必要な情報を含む' do
        post_record = create(:third_post, account: admin)
        account.favorites.create!(favoritable: post_record)

        get api_v1_posts_path
        post_json = response.parsed_body['posts'].find { |p| p['id'] == post_record.id }
        expect(post_json).to include(
          'title' => post_record.title,
          'genre' => '注意',
          'region' => '近畿',
          'favorites_count' => 1,
          'favorited' => true
        )
        expect(post_json['account']).to include('id' => admin.id, 'name' => admin.name)
        expect(response.parsed_body['meta']).to include('current_page' => 1, 'total_pages' => 1)
      end

      it '地域で検索できる（region_eq）' do
        tokai_post = create(:second_post, account: admin)  # 東海(4)
        create(:third_post, account: admin)                # 近畿(5)

        get api_v1_posts_path, params: { q: { region_eq: 4 } }
        ids = response.parsed_body['posts'].map { |post| post['id'] }
        expect(ids).to contain_exactly(tokai_post.id)
      end

      it 'キーワードで検索できる（title_or_description_cont）' do
        hit = create(:first_post, account: admin)          # タイトル: 凍結注意
        create(:third_post, account: admin)

        get api_v1_posts_path, params: { q: { title_or_description_cont: '凍結' } }
        ids = response.parsed_body['posts'].map { |post| post['id'] }
        expect(ids).to contain_exactly(hit.id)
      end

      it '都道府県（複数）で検索できる（prefecture_eq_any）' do
        hokkaido = create(:hokkaido_post, account: admin)  # 北海道(0)
        aomori = create(:aomori_post, account: admin)      # 青森(1)
        create(:tokyo_post, account: admin)                # 東京(12)

        get api_v1_posts_path, params: { q: { prefecture_eq_any: [0, 1] } }
        ids = response.parsed_body['posts'].map { |post| post['id'] }
        expect(ids).to contain_exactly(hokkaido.id, aomori.id)
      end

      it '分類（複数）で検索できる（genre_eq_any）' do
        osusume = create(:fourth_post, account: admin)     # オススメ(0)
        create(:third_post, account: admin)                # 注意(2)

        get api_v1_posts_path, params: { q: { genre_eq_any: [0] } }
        ids = response.parsed_body['posts'].map { |post| post['id'] }
        expect(ids).to contain_exactly(osusume.id)
      end
    end

    context 'ログイン済み（地域設定なし）の場合' do
      it '全地域の投稿を返す' do
        create(:third_post, account: admin)
        create(:second_post, account: admin)
        sign_in no_region_account

        get api_v1_posts_path
        expect(response.parsed_body['posts'].size).to eq 2
      end
    end
  end

  describe 'GET /api/v1/posts/:id' do
    it '投稿詳細を返す' do
      post_record = create(:third_post, account: admin)
      sign_in account
      get api_v1_post_path(post_record)
      expect(response).to have_http_status(200)
      expect(response.parsed_body.dig('post', 'id')).to eq post_record.id
    end

    it '存在しない投稿は 404 を返す' do
      sign_in account
      get api_v1_post_path(0)
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST /api/v1/posts' do
    let(:valid_params) do
      { post: { title: 'テスト投稿', description: '説明文', genre: 'オススメ', region: '関東',
                prefecture: '東京', place: 'ChIJTESTPLACEID', latitude: 35.68, longitude: 139.76 } }
    end

    before { sign_in account }

    it '投稿を作成できる' do
      expect {
        post api_v1_posts_path, params: valid_params
      }.to change(Post, :count).by(1)
      expect(response).to have_http_status(201)
      expect(response.parsed_body['message']).to eq '情報を登録しました'
      expect(response.parsed_body.dig('post', 'account', 'id')).to eq account.id
    end

    it 'アップロード済みの signed_id を渡すと写真付きで投稿できる' do
      params = valid_params.deep_dup
      params[:post][:photo_signed_ids] = [create_upload_blob.signed_id, create_upload_blob.signed_id]
      post api_v1_posts_path, params: params
      expect(response).to have_http_status(201)
      expect(Post.last.photos.count).to eq 2
      expect(response.parsed_body.dig('post', 'photos').size).to eq 2
      expect(response.parsed_body.dig('post', 'photos', 0, 'thumb_url')).to include '/rails/active_storage/'
      expect(response.parsed_body.dig('post', 'photos', 0, 'signed_id')).to be_present
    end

    it '不正な signed_id は 422 を返す' do
      params = valid_params.deep_dup
      params[:post][:photo_signed_ids] = ['invalid-signed-id']
      expect {
        post api_v1_posts_path, params: params
      }.not_to change(Post, :count)
      expect(response).to have_http_status(422)
    end

    it 'バリデーションエラー時は 422 とエラーメッセージを返す' do
      post api_v1_posts_path, params: { post: valid_params[:post].merge(title: '') }
      expect(response).to have_http_status(422)
      expect(response.parsed_body['errors']).to include 'タイトルを入力してください'
    end

    it '存在しない地域名は 422 を返す（旧コードでは 500 になっていたケース）' do
      post api_v1_posts_path, params: { post: valid_params[:post].merge(region: '鹿児島') }
      expect(response).to have_http_status(422)
    end

    it 'location_accuracy 未指定は安全側の approximate として作成される' do
      post api_v1_posts_path, params: valid_params
      expect(response).to have_http_status(201)
      expect(response.parsed_body.dig('post', 'location_accuracy')).to eq 'approximate'
      expect(response.parsed_body.dig('post', 'place')).to be_nil
    end

    it 'exact を指定すると座標・place がそのまま保存される' do
      post api_v1_posts_path, params: { post: valid_params[:post].merge(location_accuracy: 'exact') }
      expect(response).to have_http_status(201)
      post_json = response.parsed_body['post']
      expect(post_json['location_accuracy']).to eq 'exact'
      expect(post_json['place']).to eq 'ChIJTESTPLACEID'
    end

    it 'おおまか投稿はレスポンスの座標が丸め済みで place が null になる' do
      params = { post: valid_params[:post].merge(location_accuracy: 'approximate', latitude: 35.681234, longitude: 139.764321) }
      post api_v1_posts_path, params: params
      expect(response).to have_http_status(201)
      post_json = response.parsed_body['post']
      expect(post_json['location_accuracy']).to eq 'approximate'
      expect(post_json['latitude']).to be_within(1e-9).of(35.68)
      expect(post_json['longitude']).to be_within(1e-9).of(139.76)
      expect(post_json['place']).to be_nil
    end

    it '位置なし投稿は座標と place を送っても null で作成される' do
      post api_v1_posts_path, params: { post: valid_params[:post].merge(location_accuracy: 'no_location') }
      expect(response).to have_http_status(201)
      post_json = response.parsed_body['post']
      expect(post_json['location_accuracy']).to eq 'no_location'
      expect(post_json['latitude']).to be_nil
      expect(post_json['longitude']).to be_nil
      expect(post_json['place']).to be_nil
    end

    it '不正な location_accuracy は 422 を返す' do
      post api_v1_posts_path, params: { post: valid_params[:post].merge(location_accuracy: 'unknown') }
      expect(response).to have_http_status(422)
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    let!(:post_record) { create(:third_post, account: account) }

    it '投稿者本人は更新できる' do
      sign_in account
      patch api_v1_post_path(post_record), params: { post: { title: '更新後タイトル' } }
      expect(response).to have_http_status(200)
      expect(response.parsed_body['message']).to eq '情報を更新しました'
      expect(post_record.reload.title).to eq '更新後タイトル'
    end

    it '他人の投稿は 403 を返す' do
      sign_in no_region_account
      patch api_v1_post_path(post_record), params: { post: { title: '更新後タイトル' } }
      expect(response).to have_http_status(403)
      expect(post_record.reload.title).not_to eq '更新後タイトル'
    end

    describe '写真の編集（photo_signed_ids による全量置き換え）' do
      before do
        sign_in account
        post_record.photos.attach([create_upload_blob, create_upload_blob])
      end

      it '残す写真の signed_id と新規アップロードの signed_id を送ると、含めなかった写真は削除される' do
        keep_blob, remove_blob = post_record.photos.blobs.to_a
        new_blob = create_upload_blob

        patch api_v1_post_path(post_record), params: {
          post: { photo_signed_ids: [keep_blob.signed_id, new_blob.signed_id] }
        }, as: :json
        expect(response).to have_http_status(200)
        expect(post_record.reload.photos.blobs.map(&:id)).to contain_exactly(keep_blob.id, new_blob.id)
        expect(ActiveStorage::Attachment.exists?(blob_id: remove_blob.id)).to be false
      end

      it '空配列を送ると写真をすべて削除できる' do
        patch api_v1_post_path(post_record), params: { post: { photo_signed_ids: [] } }, as: :json
        expect(response).to have_http_status(200)
        expect(post_record.reload.photos.attached?).to be false
      end

      it 'photo_signed_ids を送らなければ写真は変更されない' do
        patch api_v1_post_path(post_record), params: { post: { title: '写真そのまま' } }
        expect(response).to have_http_status(200)
        expect(post_record.reload.photos.count).to eq 2
      end

      it '5枚以上は 422 を返す' do
        signed_ids = Array.new(5) { create_upload_blob.signed_id }
        patch api_v1_post_path(post_record), params: { post: { photo_signed_ids: signed_ids } }, as: :json
        expect(response).to have_http_status(422)
        expect(post_record.reload.photos.count).to eq 2
      end
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    let!(:post_record) { create(:third_post, account: account) }

    it '投稿者本人は削除できる' do
      sign_in account
      expect {
        delete api_v1_post_path(post_record)
      }.to change(Post, :count).by(-1)
      expect(response.parsed_body['message']).to eq '情報を削除しました'
    end

    it '管理者は他人の投稿を削除できる' do
      sign_in admin
      expect {
        delete api_v1_post_path(post_record)
      }.to change(Post, :count).by(-1)
    end

    it '管理者でない他人は削除できない' do
      sign_in no_region_account
      expect {
        delete api_v1_post_path(post_record)
      }.not_to change(Post, :count)
      expect(response).to have_http_status(403)
    end
  end
end
