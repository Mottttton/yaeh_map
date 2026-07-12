require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
  let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }
  describe 'バリデーションのテスト' do
    context 'いいねを登録する' do
      it '成功する' do
        second_account_post = second_account.posts.first
        fav = second_account_post.favorites.build()
        first_account.favorites << fav
        expect(fav).to be_valid
      end
    end
    context '同じ投稿にいいねを登録する' do
      it '失敗する' do
        second_account_post = second_account.posts.first
        first_fav = second_account_post.favorites.build()
        first_account.favorites << first_fav
        expect(first_fav).to be_valid
        second_fav = second_account_post.favorites.build()
        first_account.favorites << second_fav
        expect(second_fav).to be_invalid
        expect(second_fav.errors.full_messages).to eq ['いいね済みです']
      end
    end
  end
end
