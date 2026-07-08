require 'rails_helper'

RSpec.describe 'Api::V1::Favorites', type: :request do
  let!(:owner) { create(:first_account) }
  let!(:account) { create(:second_account) }
  let!(:post_record) { create(:third_post, account: owner) }

  describe 'POST /api/v1/posts/:post_id/favorite' do
    it 'いいねを登録できる' do
      sign_in account
      expect {
        post api_v1_post_favorite_path(post_record)
      }.to change(Favorite, :count).by(1)
      expect(response).to have_http_status(201)
      expect(response.parsed_body).to include('favorited' => true, 'favorites_count' => 1)
    end

    it '同じ投稿への重複いいねは 422 を返す' do
      account.favorites.create!(favoritable: post_record)
      sign_in account
      expect {
        post api_v1_post_favorite_path(post_record)
      }.not_to change(Favorite, :count)
      expect(response).to have_http_status(422)
      expect(response.parsed_body['errors']).to include 'いいね済みです'
    end

    it '未ログインは 401 を返す' do
      post api_v1_post_favorite_path(post_record)
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /api/v1/posts/:post_id/favorite' do
    it 'いいねを解除できる' do
      account.favorites.create!(favoritable: post_record)
      sign_in account
      expect {
        delete api_v1_post_favorite_path(post_record)
      }.to change(Favorite, :count).by(-1)
      expect(response).to have_http_status(200)
      expect(response.parsed_body).to include('favorited' => false, 'favorites_count' => 0)
    end
  end
end
