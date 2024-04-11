require 'rails_helper'

RSpec.describe "Favorites", type: :system do

  describe '機能要件' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    before do
      visit new_account_session_path
      fill_in('account_email', with: 'taro@sample.com')
      fill_in('account_password', with: 'password')
      click_button('ログイン')
    end
    describe 'お気に入りの登録削除' do
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
  end
end
