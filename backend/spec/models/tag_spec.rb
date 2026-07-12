require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:first_account) { FactoryBot.create(:first_account, :with_posts) }
  describe 'バリデーションのテスト' do
    context 'タグの文字が空文字の場合' do
      it 'バリデーションに失敗する' do
        first_post = first_account.posts.first
        tag = first_account.tags.build(name: '')
        first_post.tags << tag
        expect(tag).to be_invalid
        expect(tag.errors.full_messages).to eq ['タグ名を入力してください']
      end
    end
    context 'タグの文字が空文字の場合' do
      it 'バリデーションに失敗する' do
        first_post = first_account.posts.first
        tag = first_account.tags.build(name: '冬季')
        first_post.tags << tag
        expect(tag).to be_valid
      end
    end
  end
end
