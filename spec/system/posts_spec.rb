require 'rails_helper'

RSpec.describe "Posts", type: :system do
  include SigninMacro
  include CheckTimelineState

  describe '登録機能' do
    let!(:first_account) { FactoryBot.create(:first_account) }
    before do
      signin_as(first_account)
      sleep(0.5)
    end
    context '場所の検索やピンを設置しない場合' do
      it '現在地または東京駅の位置情報で新規投稿できる' do
        visit new_post_path
        sleep(7)
        fill_in('post_title', with: '現在地テスト')
        fill_in('post_description', with: 'テスト投稿')
        choose('post_genre_2')
        sleep(1)
        click_button("create-post") # [投稿する]ボタン
        expect(page).to have_text('情報を登録しました')
        timeline = all("#timeline .post")
        expect(timeline[0].text).to have_text("現在地テスト")
        expect(timeline[0].text).to have_text("テスト投稿")
      end
    end
    context '場所を検索した場合' do
      it '検索した地点の位置情報情報で新規投稿できる' do
        visit new_post_path
        sleep(7)
        fill_in('post_title', with: '東京駅')
        fill_in('post_description', with: 'テスト投稿')
        choose('post_genre_2')
        fill_in('placeSearch', with: '東京駅')
        click_button("search-location-btn") # [検索]ボタン
        sleep(1)
        click_button("create-post") # [投稿する]ボタン
        expect(page).to have_text('情報を登録しました')
        timeline = all("#timeline .post")
        expect(timeline[0].text).to have_text("東京駅")
        expect(timeline[0].text).to have_text("テスト投稿")
        expect(timeline[0].text).to have_text("関東")
      end
    end
    context '現在地を取得した場合' do
      it '現在地で新規投稿できる' do
        visit new_post_path
        sleep(7)
        fill_in('post_title', with: '現在地テスト')
        fill_in('post_description', with: 'テスト投稿')
        choose('post_genre_2')
        fill_in('placeSearch', with: '東京駅')
        click_button("search-location-btn") # [検索]ボタン
        sleep(1)
        tokyo_sta_lat = find("#post_latitude", visible: false).value
        tokyo_sta_lng = find("#post_longitude", visible: false).value
        click_button("current_location") # [現在地]ボタン
        sleep(5)
        expect(find("#post_latitude", visible: false).value).not_to eq tokyo_sta_lat
        expect(find("#post_longitude", visible: false).value).not_to eq tokyo_sta_lng
        click_button("create-post") # [投稿する]ボタン
        expect(page).to have_text('情報を登録しました')
        timeline = all("#timeline .post")
        expect(timeline[0].text).to have_text("現在地テスト")
        expect(timeline[0].text).to have_text("テスト投稿")
      end
    end
  end

  describe '一覧表示機能' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    before do
      signin_as(first_account)
      sleep(0.5)
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
        sleep(7)
        fill_in('post_title', with: 'スリップ注意')
        fill_in('post_description', with: '山間部はところどころ凍結しています。')
        choose('post_genre_2')
        fill_in('placeSearch', with: '長野県松本市')
        click_button("search-location-btn") # [検索]ボタン
        sleep(1)
        click_button("create-post") # [投稿する]ボタン

        timeline = all("#timeline .post")
        expect(timeline[0].text).to have_text("スリップ注意")
        expect(timeline[1].text).to have_text("駅前駐車場")
        expect(timeline[2].text).to have_text("工事中。片側1車線で交互に通行しています。")
        expect(timeline[3].text).to have_text("凍結注意")
      end
    end
  end

  describe '詳細画面' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    context '自分の投稿詳細画面にアクセスした場合' do
      before do
        signin_as(first_account)
        sleep(0.5)
      end
      it '編集ボタンが表示されている' do
        my_post = first_account.posts.first
        visit post_path(my_post.id)
        expect(page).to have_link("edit-post")
      end
      it '削除ボタンが表示されている' do
        my_post = first_account.posts.first
        visit post_path(my_post.id)
        expect(page).to have_link("destroy-post")
      end
    end

    context '他の人の投稿詳細画面にアクセスした場合' do
      before do
        signin_as(first_account)
        sleep(0.5)
      end
      it '編集ボタンが表示されていない' do
        anothers_post = second_account.posts.first
        visit post_path(anothers_post.id)
        expect(page).not_to have_link("edit-post")
      end
      it '削除ボタンが表示されていない' do
        anothers_post = second_account.posts.first
        visit post_path(anothers_post.id)
        expect(page).not_to have_link("destroy-post")
      end
    end

    context '投稿を削除する場合' do
      before do
        signin_as(first_account)
        sleep(0.5)
      end
      it '自分の投稿を削除できる' do
        my_post = first_account.posts.first
        visit post_path(my_post.id)
        click_link('destroy-post')
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_text("情報を削除しました")
      end
    end
  end

  describe '編集画面' do
    let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
    let!(:second_account) { FactoryBot.create(:second_account, :with_posts) }

    context '自分の投稿編集画面にアクセスした場合' do
      before do
        signin_as(first_account)
        sleep(0.5)
      end
      it '入力欄に登録された内容が表示されている' do
        my_post = first_account.posts.first
        visit edit_post_path(my_post.id)
        title_input = find_by_id("post_title").value
        post_form = find('form')
        expect(title_input).to eq my_post.title
        expect(post_form.text).to have_text(my_post.description)
      end
      it '編集した内容が反映されている' do
        my_post = first_account.posts.first
        visit post_path(my_post.id)
        expect(page).to have_text my_post.title
        expect(page).to have_text(my_post.description)
        expect(page).to have_text(my_post.region)
        expect(page).to have_text(my_post.prefecture)
        expect(page).to have_text(my_post.genre)

        visit edit_post_path(my_post.id)
        fill_in('post_title', with: '東京駅')
        fill_in('post_description', with: 'テスト投稿')
        choose('post_genre_0')
        fill_in('placeSearch', with: '東京駅')
        click_button("search-location-btn") # [検索]ボタン
        sleep(1)
        click_button("update-post") # [投稿する]ボタン
        expect(page).to have_text('情報を更新しました')
        expect(page).to have_text("東京駅")
        expect(page).to have_text("テスト投稿")
        expect(page).to have_text("関東")
        expect(page).to have_text("オススメ")
      end
    end
    context '他の人の投稿編集画面にアクセスした場合' do
      before do
        signin_as(first_account)
        sleep(0.5)
      end
      it '投稿一覧ページにリダイレクトされる' do
        anothers_post = second_account.posts.first
        visit edit_post_path(anothers_post.id)
        expect(page).to have_text("アクセス権限がありません")
        expect(page).to have_text("投稿一覧")
      end
    end
  end

  describe '検索機能' do
    let!(:no_region_account) {FactoryBot.create(:no_region_account)}
    let!(:set_region_account) {FactoryBot.create(:set_region_account)}
    let!(:posts_all_region_account) {FactoryBot.create(:posts_all_region_account, :with_posts)}
    describe '検索せずに情報一覧ページにアクセス' do
      context 'アカウントに地域の設定をしていない場合' do
        before do
          signin_as(no_region_account)
          sleep(0.5)
        end
        it 'タイムラインに全ての地域の投稿が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)
        end
      end
      context 'アカウントに地域の設定をしている場合' do
        before do
          signin_as(set_region_account)
          sleep(0.5)
        end
        it '設定した地域の投稿のみ表示されている' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)
        end
        it '何も選択せずに検索すると全ての投稿が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)
        end
      end
    end
    describe 'キーワード検索' do
      context 'アカウントに地域の設定をしていない場合' do
        before do
          signin_as(no_region_account)
          sleep(0.5)
        end
        it '検索したキーワードを全国から検索し表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)

          fill_in('q_title_or_description_cont', with: '前橋')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).not_to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).not_to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).not_to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).not_to have_text('千葉')
          expect(posts_in_timeline).not_to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).not_to have_text('富山')
          expect(posts_in_timeline).not_to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).not_to have_text('山梨')
          expect(posts_in_timeline).not_to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).not_to have_text('静岡')
          expect(posts_in_timeline).not_to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).not_to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).not_to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).not_to have_text('和歌山')
          expect(posts_in_timeline).not_to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).not_to have_text('広島')
          expect(posts_in_timeline).not_to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).not_to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).not_to have_text('高知')
          expect(posts_in_timeline).not_to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).not_to have_text('熊本')
          expect(posts_in_timeline).not_to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).not_to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
      context 'アカウントに地域の設定をしている場合' do
        before do
          signin_as(set_region_account)
          sleep(0.5)
        end
        it '検索したキーワードを全国から検索し表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)

          fill_in('q_title_or_description_cont', with: '高松')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).not_to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).not_to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).not_to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).not_to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).not_to have_text('千葉')
          expect(posts_in_timeline).not_to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).not_to have_text('富山')
          expect(posts_in_timeline).not_to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).not_to have_text('山梨')
          expect(posts_in_timeline).not_to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).not_to have_text('静岡')
          expect(posts_in_timeline).not_to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).not_to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).not_to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).not_to have_text('和歌山')
          expect(posts_in_timeline).not_to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).not_to have_text('広島')
          expect(posts_in_timeline).not_to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).not_to have_text('高知')
          expect(posts_in_timeline).not_to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).not_to have_text('熊本')
          expect(posts_in_timeline).not_to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).not_to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
    end
    describe '地域フィルタ' do
      context 'アカウントに地域の設定をしていない場合' do
        before do
          signin_as(no_region_account)
          sleep(0.5)
        end
        it '選択した地域の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)

          select('九州', from: 'q_region_eq')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          check_kyushu(posts_in_timeline)
        end
      end
      context 'アカウントに地域の設定をしている場合' do
        before do
          signin_as(set_region_account)
          sleep(0.5)
        end
        it '選択した地域の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)

          select('東北', from: 'q_region_eq')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          check_tohoku(posts_in_timeline)
        end
      end
    end
    describe '都道府県フィルタ' do
      context 'アカウントに地域の設定をしていない場合' do
        before do
          signin_as(no_region_account)
          sleep(0.5)
        end
        it '選択した都道府県の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)

          check('q_prefecture_eq_any_0')
          check('q_prefecture_eq_any_11')
          check('q_prefecture_eq_any_16')
          check('q_prefecture_eq_any_19')
          check('q_prefecture_eq_any_22')
          check('q_prefecture_eq_any_29')
          check('q_prefecture_eq_any_34')
          check('q_prefecture_eq_any_38')
          check('q_prefecture_eq_any_43')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).not_to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).not_to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).not_to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).to have_text('千葉')
          expect(posts_in_timeline).not_to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).not_to have_text('富山')
          expect(posts_in_timeline).to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).not_to have_text('山梨')
          expect(posts_in_timeline).to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).not_to have_text('静岡')
          expect(posts_in_timeline).to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).not_to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).not_to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).to have_text('和歌山')
          expect(posts_in_timeline).not_to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).not_to have_text('広島')
          expect(posts_in_timeline).to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).not_to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).to have_text('高知')
          expect(posts_in_timeline).not_to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).not_to have_text('熊本')
          expect(posts_in_timeline).to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).not_to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
      context 'アカウントに地域の設定をしている場合' do
        before do
          signin_as(set_region_account)
          sleep(0.5)
        end
        it '選択した都道府県の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)

          check('q_prefecture_eq_any_0')
          check('q_prefecture_eq_any_11')
          check('q_prefecture_eq_any_16')
          check('q_prefecture_eq_any_19')
          check('q_prefecture_eq_any_22')
          check('q_prefecture_eq_any_29')
          check('q_prefecture_eq_any_34')
          check('q_prefecture_eq_any_38')
          check('q_prefecture_eq_any_43')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).not_to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).not_to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).not_to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).to have_text('千葉')
          expect(posts_in_timeline).not_to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).not_to have_text('富山')
          expect(posts_in_timeline).to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).not_to have_text('山梨')
          expect(posts_in_timeline).to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).not_to have_text('静岡')
          expect(posts_in_timeline).to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).not_to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).not_to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).to have_text('和歌山')
          expect(posts_in_timeline).not_to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).not_to have_text('広島')
          expect(posts_in_timeline).to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).not_to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).to have_text('高知')
          expect(posts_in_timeline).not_to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).not_to have_text('熊本')
          expect(posts_in_timeline).to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).not_to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
    end
    describe '分類フィルタ' do
      context 'アカウントに地域の設定をしていない場合' do
        before do
          signin_as(no_region_account)
          sleep(0.5)
        end
        it '選択した分類の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_all_region(posts_in_timeline)

          check('q_genre_eq_any_0')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).not_to have_text('千葉')
          expect(posts_in_timeline).to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).to have_text('富山')
          expect(posts_in_timeline).not_to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).to have_text('山梨')
          expect(posts_in_timeline).not_to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).to have_text('静岡')
          expect(posts_in_timeline).not_to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).not_to have_text('和歌山')
          expect(posts_in_timeline).to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).to have_text('広島')
          expect(posts_in_timeline).not_to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).not_to have_text('高知')
          expect(posts_in_timeline).to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).to have_text('熊本')
          expect(posts_in_timeline).not_to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
      context 'アカウントに地域の設定をしている場合' do
        before do
          signin_as(set_region_account)
          sleep(0.5)
        end
        it '選択した分類の情報が表示される' do
          posts_in_timeline = find_by_id('timeline')
          check_kinki(posts_in_timeline)

          check('q_genre_eq_any_0')
          click_button('検索')
          sleep(0.5)
          posts_in_timeline = find_by_id('timeline')
          expect(posts_in_timeline).to have_text('北海道')
          expect(posts_in_timeline).not_to have_text('青森')
          expect(posts_in_timeline).not_to have_text('岩手')
          expect(posts_in_timeline).to have_text('宮城')
          expect(posts_in_timeline).not_to have_text('秋田')
          expect(posts_in_timeline).not_to have_text('山形')
          expect(posts_in_timeline).to have_text('福島')
          expect(posts_in_timeline).not_to have_text('茨城')
          expect(posts_in_timeline).not_to have_text('栃木')
          expect(posts_in_timeline).to have_text('群馬')
          expect(posts_in_timeline).not_to have_text('埼玉')
          expect(posts_in_timeline).not_to have_text('千葉')
          expect(posts_in_timeline).to have_text('東京')
          expect(posts_in_timeline).not_to have_text('神奈川')
          expect(posts_in_timeline).not_to have_text('新潟')
          expect(posts_in_timeline).to have_text('富山')
          expect(posts_in_timeline).not_to have_text('石川')
          expect(posts_in_timeline).not_to have_text('福井')
          expect(posts_in_timeline).to have_text('山梨')
          expect(posts_in_timeline).not_to have_text('長野')
          expect(posts_in_timeline).not_to have_text('岐阜')
          expect(posts_in_timeline).to have_text('静岡')
          expect(posts_in_timeline).not_to have_text('愛知')
          expect(posts_in_timeline).not_to have_text('三重')
          expect(posts_in_timeline).to have_text('滋賀')
          expect(posts_in_timeline).not_to have_text('京都')
          expect(posts_in_timeline).not_to have_text('大阪')
          expect(posts_in_timeline).to have_text('兵庫')
          expect(posts_in_timeline).not_to have_text('奈良')
          expect(posts_in_timeline).not_to have_text('和歌山')
          expect(posts_in_timeline).to have_text('鳥取')
          expect(posts_in_timeline).not_to have_text('島根')
          expect(posts_in_timeline).not_to have_text('岡山')
          expect(posts_in_timeline).to have_text('広島')
          expect(posts_in_timeline).not_to have_text('山口')
          expect(posts_in_timeline).not_to have_text('徳島')
          expect(posts_in_timeline).to have_text('香川')
          expect(posts_in_timeline).not_to have_text('愛媛')
          expect(posts_in_timeline).not_to have_text('高知')
          expect(posts_in_timeline).to have_text('福岡')
          expect(posts_in_timeline).not_to have_text('佐賀')
          expect(posts_in_timeline).not_to have_text('長崎')
          expect(posts_in_timeline).to have_text('熊本')
          expect(posts_in_timeline).not_to have_text('大分')
          expect(posts_in_timeline).not_to have_text('宮崎')
          expect(posts_in_timeline).to have_text('鹿児島')
          expect(posts_in_timeline).not_to have_text('沖縄')
        end
      end
    end
  end
end
