require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーションのテスト' do
    let!(:first_account) { FactoryBot.create(:first_account) }
    context '情報投稿のタイトルが空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["タイトルを入力してください"]
      end
    end

    context '情報投稿の地域が未選択の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: nil, description: '札幌以北は全面凍結してそうです', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["地域を入力してください"]
      end
    end

    context '情報投稿の詳細欄が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["詳細を入力してください"]
      end
    end

    context '情報投稿の分類が未選択の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: nil, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["分類を入力してください"]
      end
    end

    context '情報投稿の位置情報が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, location_accuracy: 'exact', place: '', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["位置情報を入力してください"]
      end
    end

    context '情報投稿の経度が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: nil, longitude: 142.1427344 )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["経度を入力してください"]
      end
    end

    context '情報投稿の緯度が空文字の場合' do
      it 'バリデーションに失敗する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: nil )
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ["緯度を入力してください"]
      end
    end

    context '情報投稿に必須項目を全て入力している場合' do
      it 'バリデーションに成功する' do
        post = first_account.posts.build(title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2, place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 )
        expect(post).to be_valid
      end
    end
  end

  describe '位置精度（location_accuracy）のテスト' do
    let!(:first_account) { FactoryBot.create(:first_account) }
    let(:attrs) do
      { title: '凍結注意', region: 0, description: '札幌以北は全面凍結してそうです', genre: 2,
        place: 'X4CV+Q3H 幌加内町、北海道', latitude: 43.9719375, longitude: 142.1427344 }
    end

    context '未指定の場合' do
      it '安全側の approximate になり座標が丸められ place は保存されない' do
        post = first_account.posts.create!(attrs)
        expect(post.location_accuracy).to eq 'approximate'
        expect(post.latitude).to be_within(1e-9).of(43.97)
        expect(post.longitude).to be_within(1e-9).of(142.14)
        expect(post.place).to be_nil
      end
    end

    context 'exact の場合' do
      it '座標・place がそのまま保存される' do
        post = first_account.posts.create!(attrs.merge(location_accuracy: 'exact'))
        expect(post.location_accuracy).to eq 'exact'
        expect(post.latitude).to eq 43.9719375
        expect(post.longitude).to eq 142.1427344
        expect(post.place).to eq 'X4CV+Q3H 幌加内町、北海道'
      end

      it 'place が無い場合はバリデーションに失敗する' do
        post = first_account.posts.build(attrs.merge(location_accuracy: 'exact', place: nil))
        expect(post).to be_invalid
        expect(post.errors.full_messages).to eq ['位置情報を入力してください']
      end
    end

    context 'approximate の場合' do
      it '座標が0.01度グリッドに丸められ place が nil になる' do
        post = first_account.posts.create!(attrs.merge(location_accuracy: 'approximate'))
        expect(post.latitude).to be_within(1e-9).of(43.97)
        expect(post.longitude).to be_within(1e-9).of(142.14)
        expect(post.place).to be_nil
      end

      it '丸めは冪等で、再保存しても座標が変わらない' do
        post = first_account.posts.create!(attrs.merge(location_accuracy: 'approximate'))
        rounded = [post.latitude, post.longitude]
        post.update!(title: '更新後タイトル')
        expect([post.reload.latitude, post.longitude]).to eq rounded
      end

      it '座標が無い場合はバリデーションに失敗する' do
        post = first_account.posts.build(attrs.merge(location_accuracy: 'approximate', latitude: nil, longitude: nil))
        expect(post).to be_invalid
        expect(post.errors.full_messages).to contain_exactly('経度を入力してください', '緯度を入力してください')
      end
    end

    context 'no_location の場合' do
      it '座標と place を送っても nil にクリアされて保存できる' do
        post = first_account.posts.create!(attrs.merge(location_accuracy: 'no_location'))
        expect(post.latitude).to be_nil
        expect(post.longitude).to be_nil
        expect(post.place).to be_nil
      end
    end
  end
end
