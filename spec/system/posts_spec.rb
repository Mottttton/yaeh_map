require 'rails_helper'

RSpec.describe "Posts", type: :system do
  describe '登録機能' do
    let!(:first_account) { FactoryBot.create(:first_account) }
    before do
      visit new_account_session_path
      fill_in('account_email', with: 'taro@sample.com')
      fill_in('account_password', with: 'password')
      click_button('ログイン')
    end
    context '情報を登録した場合' do
      it '登録した情報が表示される' do
        visit new_post_path
        sleep(5)
        fill_in('post_title', with: '凍結注意')
        fill_in('post_description', with: '山間部はところどころ凍結しています。')
        select('注意', from: 'post_genre')
        select('北陸', from: 'post_region')
        select('長野', from: 'post_prefecture')
        fill_in('post_place', with: 'ChIJHUi0-YT-HGAR5D3l9F8xY1o')
        fill_in('post_latitude', with: '36.00457135732795')
        fill_in('post_longitude', with: '138.0080174668216')
        click_button("create-post") # [投稿する]ボタン
        expect(page).to have_text('情報を登録しました')
        expect(page).to have_text('凍結注意')
        expect(page).to have_text('注意')
        expect(page).to have_text('北陸')
        expect(page).to have_text('長野')
      end
    end
  end

  describe '一覧表示機能' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    before do
      visit new_account_session_path
      fill_in('account_email', with: 'taro@sample.com')
      fill_in('account_password', with: 'password')
      click_button('ログイン')
    end

    context '一覧画面に遷移した場合' do
      it '登録済みの情報一覧が作成日時の降順で表示される' do
        timeline = all("#timeline .post")
        expect(timeline[0].text).to have_text("駅前駐車場")
        expect(timeline[1].text).to have_text("工事中。片側1車線で交互に通行しています。")
        expect(timeline[2].text).to have_text("凍結注意")
      end
    end
    context '新たに情報を作成した場合' do
      it '新しい情報が一番上に表示される' do
        visit new_post_path
        sleep(5)
        binding.irb
        fill_in('post_title', with: 'スリップ注意')
        fill_in('post_description', with: '山間部はところどころ凍結しています。')
        select('注意', from: 'post_genre')
        select('北陸', from: 'post_region')
        select('長野', from: 'post_prefecture')
        fill_in('post_place', with: 'ChIJHUi0-YT-HGAR5D3l9F8xY1o')
        fill_in('post_latitude', with: '36.00457135732795')
        fill_in('post_longitude', with: '138.0080174668216')
        click_button("create-post") # [投稿する]ボタン

        timeline = all("#timeline .post")
        binding.irb
        expect(timeline[0].text).to have_text("スリップ注意")
        expect(timeline[1].text).to have_text("駅前駐車場")
        expect(timeline[2].text).to have_text("工事中。片側1車線で交互に通行しています。")
        expect(timeline[3].text).to have_text("凍結注意")
      end
    end
  end
end
