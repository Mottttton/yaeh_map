require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーションのテスト' do
    let!(:first_account) { FactoryBot.create(:first_account) }
    context '情報投稿のタイトルが空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place_id: 'X4CV+Q3H 幌加内町、北海道' )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["タイトルを入力してください"]
      end
    end

    context '情報投稿の地域が未選択の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: nil, description: '札幌以北は全面凍結してそうです', genre: 2, place_id: 'X4CV+Q3H 幌加内町、北海道' )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["地域を入力してください"]
      end
    end

    context '情報投稿の詳細欄が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '', genre: 2, place_id: 'X4CV+Q3H 幌加内町、北海道' )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["詳細を入力してください"]
      end
    end

    context '情報投稿の分類が未選択の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: nil, place_id: 'X4CV+Q3H 幌加内町、北海道' )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["分類を入力してください"]
      end
    end

    context '情報投稿の位置情報が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place_id: '' )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["位置情報を入力してください"]
      end
    end

    context '情報投稿に必須項目を全て入力している場合' do
      it 'バリデーションに成功する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place_id: 'X4CV+Q3H 幌加内町、北海道' )
        expect(post).to be_valid
      end
    end
  end
end
