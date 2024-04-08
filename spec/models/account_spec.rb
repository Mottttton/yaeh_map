require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'バリデーションのテスト' do
    context 'アカウント名が空文字の場合' do
      it 'バリデーションに失敗する' do
        account = Account.new(name: '', email: 'taro@sample.com', nickname: 'taro', password: 'password', password_confirmation: 'password')
        account.skip_confirmation!
        account.save
        expect(account).to be_invalid
        expect(account.errors.full_messages).to eq ['アカウント名を入力してください']
      end
    end

    context 'アカウント名がすでに使用されていた場合' do
      it 'バリデーションに失敗する' do
        account1 = Account.new(name: 'taro', email: 'taro@sample.com', nickname: 'yamataro', password: 'password', password_confirmation: 'password')
        account1.skip_confirmation!
        account1.save
        expect(account1).to be_valid
        account2 = Account.create(name: 'taro', email: 'taro@sample.com', nickname: 'tanataro', password: 'drowssap', password_confirmation: 'drowssap')
        account2.skip_confirmation!
        account2.save
        expect(account2).to be_invalid
        expect(account2.errors.full_messages).to include 'アカウント名はすでに使用されています'
      end
    end

    context 'アカウントのメールアドレスが空文字の場合' do
      it 'バリデーションに失敗する' do
        account = Account.new(name: 'taro', email: '', nickname: 'taro', password: 'password', password_confirmation: 'password')
        account.skip_confirmation!
        account.save
        expect(account).to be_invalid
        expect(account.errors.full_messages).to include 'メールアドレスを入力してください'
      end
    end

    context 'アカウントのメールアドレスがすでに使用されていた場合' do
      it 'バリデーションに失敗する' do
        account1 = Account.new(name: 'yamada_taro', email: 'taro@sample.com', nickname: 'yamataro', password: 'password', password_confirmation: 'password')
        account1.skip_confirmation!
        account1.save
        expect(account1).to be_valid
        account2 = Account.new(name: 'tanaka_taro', email: 'taro@sample.com', nickname: 'tanataro', password: 'drowssap', password_confirmation: 'drowssap')
        account2.skip_confirmation!
        account2.save
        expect(account2).to be_invalid
        expect(account2.errors.full_messages).to include 'メールアドレスはすでに使用されています'
      end
    end

    context 'ニックネームが空文字の場合' do
      it 'バリデーションに失敗する' do
        account = Account.new(name: 'taro', email: 'taro@sample.com', nickname: '', password: 'password', password_confirmation: 'password')
        account.skip_confirmation!
        account.save
        expect(account).to be_invalid
        expect(account.errors.full_messages).to eq ['ニックネームを入力してください']
      end
    end

    context 'アカウントのパスワードが空文字の場合' do
      it 'バリデーションに失敗する' do
        account = Account.new(name: 'taro', email: 'taro@sample.com', nickname: 'taro', password: '', password_confirmation: 'password')
        account.skip_confirmation!
        account.save
        expect(account).to be_invalid
        expect(account.errors.full_messages).to include 'パスワードを入力してください'
      end
    end

    context 'アカウントのパスワードが6文字未満の場合' do
      it 'バリデーションに失敗する' do
        account = Account.new(name: 'taro', email: 'taro@sample.com', nickname: 'taro', password: 'passw', password_confirmation: 'passw')
        account.skip_confirmation!
        account.save
        expect(account).to be_invalid
        expect(account.errors.full_messages).to eq ['パスワードは6文字以上で入力してください']
      end
    end

    context 'アカウントのパスワードが6文字の場合' do
      it 'バリデーションに成功する' do
        account = Account.new(name: 'taro', email: 'taro@sample.com', nickname: 'taro', password: 'passwo', password_confirmation: 'passwo')
        account.skip_confirmation!
        account.save
        expect(account).to be_valid
      end
    end

    context 'アカウント名が使われていない値、メールアドレスが使われていない値で、かつパスワードが6文字以上の場合' do
      it 'バリデーションに成功する' do
        account1 = Account.new(name: 'yamada_taro', email: 'yamadataro@sample.com', nickname: 'taro', password: 'password', password_confirmation: 'password')
        account1.skip_confirmation!
        account1.save
        expect(account1).to be_valid
        account2 = Account.new(name: 'tanaka_taro', email: 'tanakataro@sample.com', nickname: 'taro', password: 'password', password_confirmation: 'password')
        account2.skip_confirmation!
        account2.save
        expect(account2).to be_valid
      end
    end
  end
end
