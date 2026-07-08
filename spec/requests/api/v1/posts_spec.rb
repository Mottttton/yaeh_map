require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let!(:admin) { create(:first_account) }            # region: 近畿(5), admin: true
  let!(:account) { create(:second_account) }         # region: 近畿(5), admin: false
  let!(:no_region_account) { create(:no_region_account) } # region 未設定

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

    it '写真を添付して投稿できる' do
      params = valid_params.deep_dup
      params[:post][:photos] = [
        Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.png'), 'image/png'),
        Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.png'), 'image/png')
      ]
      post api_v1_posts_path, params: params
      expect(response).to have_http_status(201)
      expect(Post.last.photos.count).to eq 2
      expect(response.parsed_body.dig('post', 'photos').size).to eq 2
      expect(response.parsed_body.dig('post', 'photos', 0, 'thumb_url')).to include '/rails/active_storage/'
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
