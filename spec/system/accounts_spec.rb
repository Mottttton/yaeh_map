require 'rails_helper'

RSpec.describe "Accounts", type: :system do
  include SigninMacro

  describe 'アカウント登録機能テスト' do
    before do
      visit new_account_registration_path
    end
    context 'ユーザを登録した場合' do
      it '情報一覧画面に遷移する' do
        fill_in('account_name', with: 'hanako')
        fill_in('account_email', with: 'hanako@sample.com')
        fill_in('account_nickname', with: 'hanako')
        fill_in('account_password', with: 'hanakonoko')
        fill_in('account_password_confirmation', with: 'hanakonoko')
        click_button('create-account')
        expect(page).to have_content('情報一覧')
        expect(page).to have_text('アカウント登録が完了しました')
      end
    end
    context 'ログインせずに情報一覧画面に遷移した場合' do
      it 'ログイン画面に遷移し、「ログインしてください」というメッセージが表示される' do
        visit posts_path
        expect(page).to have_content('ログイン')
        expect(page).to have_button('create-session')
        expect(page).to have_content('ログインもしくはアカウント登録してください')
      end
    end
  end

  describe 'ログイン機能テスト' do
    describe '画面遷移' do
      context '登録済みの一般アカウントでログインした場合' do
        let!(:first_account) { FactoryBot.create(:first_account) }
        let!(:second_account) { FactoryBot.create(:second_account) }
        before do
          signin_as(first_account)
        end
        it '情報一覧画面に遷移し、「ログインしました」というメッセージが表示される' do
          expect(page).to have_text('情報一覧')
          expect(page).to have_text('ログインしました')
        end
        it '自分のアカウント詳細画面にアクセスできる' do
          click_link('account-detail')
          expect(page).to have_text('プロフィール詳細')
          expect(page).to have_text(first_account.name)
          expect(page).to have_text(first_account.nickname)
          expect(page).to have_text(first_account.region)
          expect(page).to have_text(first_account.self_introduction)
          expect(page).to have_link('edit-account')
        end
        it '自分のアカウント編集画面にアクセスできる' do
          click_link('account-detail')
          click_link('edit-account')
          expect(page).to have_text('プロフィール編集')
          expect(page).to have_button('update-profile')
        end
        it '他人のアカウント詳細画面にアクセスできる' do
          visit account_path(second_account.id)
          expect(page).to have_text('プロフィール詳細')
          expect(page).to have_text(second_account.name)
          expect(page).to have_text(second_account.nickname)
          expect(page).to have_text(second_account.region)
          expect(page).to have_text(second_account.self_introduction)
          expect(page).not_to have_link('edit-account')
        end
        it '他人のアカウント編集画面にアクセスすると、情報一覧画面に遷移する' do
          visit edit_account_path(second_account.id)
          expect(page).to have_text('情報一覧')
          expect(page).to have_text('アクセス権限がありません')
        end
        it 'ログアウトするとログイン画面に遷移し、「ログアウトしました」というメッセージが表示される' do
          click_link('ログアウト')
          expect(page).to have_text('ログイン')
          expect(page).to have_button('create-session')
          expect(page).to have_text('ログアウトしました')
        end
      end
    end
  end
  describe '管理者機能' do
    describe '画面遷移' do
      let!(:first_account) { FactoryBot.create(:first_account) }
      let!(:second_account) { FactoryBot.create(:second_account) }
      context '管理者アカウントでログイン' do
        before do
          signin_as(first_account)
        end
        it '管理者用ページのリンクが存在する' do
          expect(page).to have_link('admin-index')
        end
        it '管理者用ページにアクセス可能' do
          visit rails_admin_path
          expect(page).to have_text('サイト管理')
        end
      end
      context '一般アカウントでログイン' do
        before do
          signin_as(second_account)
        end
        it '管理者用ページのリンクが表示されていない' do
          expect(page).not_to have_link('admin-index')
        end
        it '管理者用ページにアクセスしようとすると情報一覧ページにリダイレクトされる' do
          visit rails_admin_path
          expect(page).not_to have_text('サイト管理')
          expect(page).to have_text('情報一覧')
          expect(page).to have_text('アクセス権限がありません')
        end
      end
    end
  end
end