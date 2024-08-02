require 'rails_helper'

RSpec.describe "Favorites", type: :system do
  include SigninMacro

  describe '機能要件' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    before do
      signin_as(first_account)
      sleep(0.5)
    end
    describe 'お気に入りの登録削除' do
      context '情報投稿一覧画面' do
        it 'お気に入りのつけ外しができる' do
          visit posts_path
          first_post = Post.first
          fav_link_locator = 'fav_link-' + first_post.id.to_s
          num_of_fav_id = 'num_of_fav-' + first_post.id.to_s

          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '0'

          click_link(fav_link_locator)
          sleep(0.5)
          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '1'

          click_link(fav_link_locator)
          sleep(0.5)
          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '0'
        end
      end
      context '情報詳細画面' do
        it 'お気に入りのつけ外しができる' do
          first_post = Post.first
          visit post_path(first_post.id)
          fav_link_locator = 'fav_link-' + first_post.id.to_s
          num_of_fav_id = 'num_of_fav-' + first_post.id.to_s

          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '0'

          click_link(fav_link_locator)
          sleep(0.5)
          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '1'

          click_link(fav_link_locator)
          sleep(0.5)
          num_of_favs = find_by_id(num_of_fav_id).text
          expect(num_of_favs).to have_content '0'
        end
      end
    end
  end
end
